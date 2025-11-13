import 'package:flutter/material.dart';
import 'package:formatic/models/flashcards/flashcard.dart';
import 'package:formatic/models/library/book.dart';
import 'package:formatic/models/tasks/task.dart';
import 'package:formatic/services/flashcards/flashcard_service.dart';
import 'package:formatic/services/library/book_service.dart';
import 'package:formatic/services/tasks/task_service.dart';
import 'package:formatic/services/core/activity_logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardContent extends StatefulWidget {
  final bool isDarkMode;
  final Function(int)? onNavigate;

  const DashboardContent({
    super.key,
    required this.isDarkMode,
    this.onNavigate,
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final _taskService = TaskService();
  final _flashcardService = FlashcardService();
  final _bookService = BookService();

  bool _isLoading = true;
  int _pendingTasks = 0;
  int _totalFlashcards = 0;
  int _totalBooks = 0;
  List<Book> _recommendedBooks = [];

  List<Map<String, dynamic>> _recentActivities = [];

  final List<Map<String, String>> _quotes = [
    {
      'text':
          'A educação é a arma mais poderosa que você pode usar para mudar o mundo.',
      'author': 'Nelson Mandela',
    },
    {
      'text':
          'O conhecimento é o único tesouro que aumenta quando compartilhado.',
      'author': 'Marie Curie',
    },
    {
      'text':
          'Você nunca é velho demais para definir um novo objetivo ou sonhar um novo sonho.',
      'author': 'C.S. Lewis',
    },
    {
      'text':
          'A mente que se abre a uma nova ideia jamais voltará ao seu tamanho original.',
      'author': 'Albert Einstein',
    },
    {
      'text': 'O sucesso é a soma de pequenos esforços repetidos dia após dia.',
      'author': 'Robert Collier',
    },
    {
      'text':
          'Não espere por oportunidades. Crie você mesmo as suas oportunidades.',
      'author': 'George Bernard Shaw',
    },
    {
      'text':
          'O único modo de fazer um excelente trabalho é amar o que você faz.',
      'author': 'Steve Jobs',
    },
    {
      'text': 'Acredite que você pode, e você já está no meio do caminho.',
      'author': 'Theodore Roosevelt',
    },
    {
      'text': 'A persistência é o caminho do êxito.',
      'author': 'Charles Chaplin',
    },
    {
      'text': 'O aprendizado nunca cansa a mente.',
      'author': 'Leonardo da Vinci',
    },
    {'text': 'Ler é sonhar pela mão de outrem.', 'author': 'Fernando Pessoa'},
    {
      'text':
          'Quanto mais você lê, mais coisas você saberá. Quanto mais você aprende, mais lugares você irá.',
      'author': 'Dr. Seuss',
    },
    {
      'text': 'Um livro é um sonho que você segura em suas mãos.',
      'author': 'Neil Gaiman',
    },
    {'text': 'A leitura engrandece a alma.', 'author': 'Voltaire'},
    {
      'text':
          'O fracasso é apenas a oportunidade de começar de novo com mais inteligência.',
      'author': 'Henry Ford',
    },
  ];

  late Map<String, String> _currentQuote;

  @override
  void initState() {
    super.initState();
    _loadQuoteForSession();
    _loadDashboardData();
  }

  void refreshData() {
    _loadDashboardData();
  }

  Future<void> _loadQuoteForSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final savedQuoteKey = 'quote_for_user_$userId';

    final savedQuoteIndex = prefs.getInt(savedQuoteKey);

    if (savedQuoteIndex != null && savedQuoteIndex < _quotes.length) {
      setState(() {
        _currentQuote = _quotes[savedQuoteIndex];
      });
    } else {
      final random = DateTime.now().millisecondsSinceEpoch % _quotes.length;
      await prefs.setInt(savedQuoteKey, random);
      setState(() {
        _currentQuote = _quotes[random];
      });
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final results = await Future.wait([
        _taskService.getTasks(),
        _flashcardService.getUserFlashcards(userId),
        _bookService.getAllBooks(),
        ActivityLoggerService.getRecentActivities(hoursLimit: 168), // 7 dias
      ]);

      final tasks = results[0] as List<Task>;
      final flashcards = results[1] as List<Flashcard>;
      final books = results[2] as List<Book>;
      final loggedActivities = results[3] as List<Map<String, dynamic>>;

      final activities = <Map<String, dynamic>>[];

      for (var activity in loggedActivities) {
        final action = activity['action'];
        final type = activity['type'];
        final itemName = activity['itemName'];
        final timestamp = DateTime.parse(activity['timestamp']);

        IconData icon;
        int pageIndex;

        if (type == ActivityLoggerService.typeTask) {
          icon = Icons.check_circle_rounded;
          pageIndex = 0;
        } else if (type == ActivityLoggerService.typeFlashcard) {
          icon = Icons.style_rounded;
          pageIndex = 1;
        } else {
          icon = Icons.book_rounded;
          pageIndex = 4;
        }

        activities.add({
          'type': type,
          'title': ActivityLoggerService.getActionText(action, type),
          'subtitle': itemName,
          'timestamp': timestamp,
          'icon': icon,
          'pageIndex': pageIndex,
        });
      }

      setState(() {
        _pendingTasks = tasks.length;
        _totalFlashcards = flashcards.length;
        _totalBooks = books.length;
        _recommendedBooks = [
          if (books.length > 2) books[2],
          if (books.length > 4) books[4],
          if (books.length > 1) books[1],
        ];
        _recentActivities = activities.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B2CF5)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFF8B2CF5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 28),

                    _buildServicesSection(),
                    const SizedBox(height: 28),

                    if (_recommendedBooks.isNotEmpty) ...[
                      _buildRecommendedBooksSection(),
                      const SizedBox(height: 28),
                    ],

                    if (_recentActivities.isNotEmpty) _buildRecentActivity(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B2CF5), Color(0xFFAA66FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B2CF5).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Inspiração do Dia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 12),
                Text(
                  _currentQuote['text']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentQuote['author']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Serviços',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildServiceButton(
              'Tarefas',
              Icons.assignment_rounded,
              const Color(0xFF8B2CF5),
              _pendingTasks.toString(),
              0,
            ),
            _buildServiceButton(
              'Flashcards',
              Icons.style_rounded,
              const Color(0xFF8B2CF5),
              _totalFlashcards.toString(),
              1,
            ),
            _buildServiceButton(
              'Biblioteca',
              Icons.auto_stories_rounded,
              const Color(0xFF8B2CF5),
              _totalBooks.toString(),
              4,
            ),
            _buildServiceButton(
              'Assistente',
              Icons.psychology_rounded,
              const Color(0xFF8B2CF5),
              'AI',
              3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceButton(
    String label,
    IconData icon,
    Color color,
    String count,
    int pageIndex,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => widget.onNavigate?.call(pageIndex),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 26),
                      ),
                      if (count != 'AI')
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              count,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Atividades Recentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        ..._recentActivities
            .take(5)
            .map(
              (activity) => _buildActivityItem(
                activity['title'] as String,
                activity['subtitle'] as String,
                activity['icon'] as IconData,
                const Color(0xFF8B2CF5),
                activity['pageIndex'] as int,
              ),
            ),
      ],
    );
  }

  Widget _buildRecommendedBooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Livros Recomendados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                  letterSpacing: -0.5,
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigate?.call(4),
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: Color(0xFF8B2CF5),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _recommendedBooks.take(3).length,
            itemBuilder: (context, index) {
              final book = _recommendedBooks[index];
              return _buildBookCard(book, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(Book book, int index) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onNavigate?.call(4),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B2CF5), Color(0xFFAA66FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B2CF5).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        book.coverImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white.withOpacity(0.1),
                            child: const Center(
                              child: Icon(
                                Icons.auto_stories_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    int pageIndex,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => widget.onNavigate?.call(pageIndex),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
