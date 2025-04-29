import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class ThemeProvider extends InheritedWidget {
  final Color seedColor;

  const ThemeProvider({
    super.key,
    required this.seedColor,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return seedColor != oldWidget.seedColor;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _currentColor = Colors.blue;

  void updateTheme(Color color) {
    setState(() {
      _currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      seedColor: _currentColor,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: '每日科普',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: _currentColor,
              ),
              useMaterial3: true,
            ),
            home: HomePage(onThemeChange: updateTheme),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(Color) onThemeChange;

  const HomePage({
    super.key,
    required this.onThemeChange,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String _currentCategory = '今日科普';
  int _currentArticleIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isForward = true;
  double _dragOffset = 0.0;
  double _dragStartX = 0.0;
  bool _isDragging = false;

  final List<String> _categories = [
    '今日科普',
    '自然科学',
    '人文历史',
    '科技创新',
    '健康生活',
    '环境保护',
    '宇宙探索',
  ];

  final Map<String, List<Map<String, String>>> _articles = {
    '今日科普': [
      {
        'title': '为什么天空是蓝色的？',
        'content': '天空呈现蓝色是因为大气层中的气体分子会散射太阳光。这种现象被称为"瑞利散射"。太阳光中的蓝光波长较短，更容易被散射，所以我们看到的天空是蓝色的。',
      },
      {
        'title': '为什么会有四季变化？',
        'content': '地球围绕太阳公转时，由于地轴倾斜，导致不同时期太阳直射点位置不同，造成季节变化。春分秋分时太阳直射赤道，夏至冬至时分别直射北回归线和南回归线。',
      },
      {
        'title': '为什么会有潮汐现象？',
        'content': '潮汐主要是由月球和太阳的引力作用造成的。月球引力使海水产生周期性涨落，形成潮汐。每月初一、十五时，太阳、地球、月球几乎在一条直线上，形成大潮。',
      },
    ],
    '自然科学': [
      {
        'title': '光合作用：植物的能量转换器',
        'content': '光合作用是植物利用阳光、二氧化碳和水制造葡萄糖的过程。这个过程不仅为植物提供能量，还能产生氧气，是地球上生命维持的重要过程。',
      },
      {
        'title': 'DNA：生命的密码',
        'content': 'DNA是携带遗传信息的双螺旋结构分子。它由四种碱基组成，通过不同的排列组合，编码着生物体的所有遗传信息。',
      },
      {
        'title': '地震：地球的脉动',
        'content': '地震是地球内部能量释放的一种形式。板块运动导致地壳应力积累，当超过岩石强度时就会发生断裂，释放能量形成地震。',
      },
    ],
    '人文历史': [
      {
        'title': '丝绸之路：东西方文明的桥梁',
        'content': '丝绸之路是古代连接中国与欧亚大陆的重要贸易路线。它不仅促进了商品交换，更推动了文化、艺术、宗教等领域的交流。',
      },
      {
        'title': '四大发明：改变世界的中国智慧',
        'content': '造纸术、指南针、火药和印刷术被称为中国古代四大发明。这些发明对世界文明发展产生了深远影响，推动了人类社会的进步。',
      },
      {
        'title': '文艺复兴：人文主义的觉醒',
        'content': '文艺复兴是欧洲14-16世纪的一场思想文化运动。它强调人的价值和尊严，推动了科学、艺术、文学等领域的发展。',
      },
    ],
    '科技创新': [
      {
        'title': '人工智能：改变未来的技术',
        'content': '人工智能正在深刻改变我们的生活。从语音助手到自动驾驶，从医疗诊断到智能制造，AI技术的应用无处不在。',
      },
      {
        'title': '量子计算：下一代计算革命',
        'content': '量子计算利用量子力学原理进行信息处理，具有远超传统计算机的运算能力。它可能在密码学、药物研发等领域带来突破。',
      },
      {
        'title': '5G：万物互联的时代',
        'content': '5G技术具有高速率、低延迟、大连接的特点，将推动物联网、自动驾驶、远程医疗等新技术的发展。',
      },
    ],
    '健康生活': [
      {
        'title': '科学饮食：营养均衡的重要性',
        'content': '均衡的营养摄入是健康的基础。合理的饮食搭配，包括适量的蛋白质、碳水化合物、脂肪、维生素和矿物质。',
      },
      {
        'title': '运动健身：保持活力的秘诀',
        'content': '规律运动能增强心肺功能，提高免疫力，预防慢性疾病。建议每周进行150分钟中等强度有氧运动。',
      },
      {
        'title': '睡眠质量：健康的关键',
        'content': '充足的睡眠对身心健康至关重要。成年人每天应保持7-8小时的睡眠时间，保证睡眠质量。',
      },
    ],
    '环境保护': [
      {
        'title': '碳中和：应对气候变化的行动',
        'content': '碳中和是指通过减少碳排放和增加碳吸收，使净碳排放量为零。这是应对全球气候变化的重要措施。',
      },
      {
        'title': '生物多样性：地球的生命网络',
        'content': '生物多样性是地球生态系统健康的重要指标。保护生物多样性对维持生态平衡和人类生存至关重要。',
      },
      {
        'title': '可再生能源：清洁能源的未来',
        'content': '太阳能、风能、水能等可再生能源是未来能源发展的方向。发展可再生能源对减少环境污染、应对气候变化具有重要意义。',
      },
    ],
    '宇宙探索': [
      {
        'title': '黑洞：宇宙的神秘天体',
        'content': '黑洞是宇宙中最神秘的天体之一，它的引力如此强大，连光都无法逃脱。科学家们通过观测黑洞周围的物质运动，不断揭示着宇宙的奥秘。',
      },
      {
        'title': '系外行星：寻找第二个地球',
        'content': '系外行星是围绕其他恒星运行的行星。科学家们正在寻找可能适合人类居住的系外行星，探索宇宙中的生命可能性。',
      },
      {
        'title': '暗物质：宇宙的隐藏力量',
        'content': '暗物质是一种看不见摸不着的物质，但它通过引力影响着宇宙的结构和演化。研究暗物质对理解宇宙本质具有重要意义。',
      },
    ],
  };

  Color _getCategoryColor(String category) {
    switch (category) {
      case '今日科普':
        return Colors.blueAccent;
      case '自然科学':
        return Colors.greenAccent;
      case '人文历史':
        return Colors.orange;
      case '科技创新':
        return Colors.pink;
      case '健康生活':
        return Colors.pink;
      case '环境保护':
        return Colors.teal;
      case '宇宙探索':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentArticleIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextArticle() {
    if (_currentArticleIndex < _articles[_currentCategory]!.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousArticle() {
    if (_currentArticleIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateTheme(String category) {
    _animationController.reverse().then((_) {
      setState(() {
        _currentCategory = category;
        _currentArticleIndex = 0;
        _pageController.jumpToPage(0);
      });
      widget.onThemeChange(_getCategoryColor(category));
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _currentCategory,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.primary),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: colorScheme.primary),
            onPressed: () {
              // TODO: 实现通知功能
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withOpacity(0.6),
                colorScheme.primaryContainer.withOpacity(0.4),
                colorScheme.primary.withOpacity(0.03),
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.local_library_rounded,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '每日科普',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ..._categories.map((category) => ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category == _currentCategory
                        ? colorScheme.primary.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: category == _currentCategory
                        ? colorScheme.primary
                        : colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                title: Text(
                  category,
                  style: TextStyle(
                    color: category == _currentCategory
                        ? colorScheme.primary
                        : colorScheme.onPrimaryContainer,
                    fontWeight: category == _currentCategory ? FontWeight.bold : null,
                    letterSpacing: 0.5,
                  ),
                ),
                selected: category == _currentCategory,
                selectedTileColor: colorScheme.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  _updateTheme(category);
                  Navigator.pop(context);
                },
              )),
              Divider(color: colorScheme.onPrimaryContainer.withOpacity(0.1)),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: colorScheme.onPrimaryContainer.withOpacity(0.7)),
                title: Text(
                  '设置',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    letterSpacing: 0.5,
                  ),
                ),
                onTap: () {
                  // TODO: 实现设置功能
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer.withOpacity(0.7)),
                title: Text(
                  '关于',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    letterSpacing: 0.5,
                  ),
                ),
                onTap: () {
                  // TODO: 实现关于功能
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.08),
              colorScheme.surface,
              colorScheme.primaryContainer.withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景装饰
            Positioned(
              right: -100,
              top: -50,
              child: Icon(
                _getCategoryIcon(_currentCategory),
                size: 200,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -30,
              child: Icon(
                Icons.auto_awesome,
                size: 150,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
            // 添加更多装饰元素
            Positioned(
              right: 50,
              bottom: 100,
              child: Icon(
                Icons.lightbulb_outline,
                size: 60,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
            Positioned(
              left: 30,
              top: 100,
              child: Icon(
                Icons.star_outline,
                size: 40,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentArticleIndex = index;
                });
              },
              itemCount: _articles[_currentCategory]!.length,
              itemBuilder: (context, index) {
                final article = _articles[_currentCategory]![index];
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 80,
                    left: 16,
                    right: 16,
                    bottom: 100,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              // colorScheme.primaryFixed.withOpacity(0.7),
                              // colorScheme.primaryFixed.withOpacity(0.6),
                              colorScheme.primaryContainer.withOpacity(0.7),
                              colorScheme.primaryContainer.withOpacity(0.6),
                              colorScheme.primaryContainer,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: -5,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.05),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              // 内容
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 页码指示器
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.article_outlined,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            '${index + 1}/${_articles[_currentCategory]!.length}',
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // 标题
                                    Text(
                                      article['title']!,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        height: 1.3,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // 内容
                                    Text(
                                      article['content']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                        color: colorScheme.onSurface,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // 导航按钮
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildNavigationButton(
                                          icon: Icons.arrow_back_ios_new,
                                          label: '上一篇',
                                          onPressed: _previousArticle,
                                          colorScheme: colorScheme,
                                        ),
                                        _buildNavigationButton(
                                          icon: Icons.arrow_forward_ios,
                                          label: '下一篇',
                                          onPressed: _nextArticle,
                                          colorScheme: colorScheme,
                                          isNext: true,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.surfaceContainerHigh,
              colorScheme.surface,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: -2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomButton(
                  icon: Icons.share_rounded,
                  label: '分享',
                  onPressed: () {
                    // TODO: 实现分享功能
                  },
                  colorScheme: colorScheme,
                ),
                _buildBottomButton(
                  icon: Icons.bookmark_border_rounded,
                  label: '收藏',
                  onPressed: () {
                    // TODO: 实现收藏功能
                  },
                  colorScheme: colorScheme,
                ),
                _buildBottomButton(
                  icon: Icons.more_horiz_rounded,
                  label: '更多',
                  onPressed: () {
                    // TODO: 实现更多功能
                  },
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
    bool isNext = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isNext) ...[
                Icon(
                  icon,
                  size: 16,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              if (isNext) ...[
                SizedBox(width: 4),
                Icon(
                  icon,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: colorScheme.primary,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '今日科普':
        return Icons.today;
      case '自然科学':
        return Icons.science;
      case '人文历史':
        return Icons.history_edu;
      case '科技创新':
        return Icons.rocket_launch;
      case '健康生活':
        return Icons.favorite;
      case '环境保护':
        return Icons.eco;
      case '宇宙探索':
        return Icons.public;
      default:
        return Icons.article;
    }
  }
}
