import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppColors.nav,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DesktopPrototypeHost(child: TeCaiGoApp()));
}

class DesktopPrototypeHost extends StatelessWidget {
  const DesktopPrototypeHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktopWeb = kIsWeb &&
            switch (defaultTargetPlatform) {
              TargetPlatform.linux ||
              TargetPlatform.macOS ||
              TargetPlatform.windows =>
                true,
              _ => false,
            };
        final framed = desktopWeb || constraints.maxWidth >= 480;
        if (!framed) return child;
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 430.0;
        final availableHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 932.0;
        final width = availableWidth >= 480 ? 430.0 : availableWidth;
        final height = availableHeight >= 720
            ? math.min(availableHeight, 932.0)
            : availableHeight;
        return ColoredBox(
          color: AppColors.canvasDeep,
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TeCaiGoApp extends StatelessWidget {
  const TeCaiGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeCaiGO',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.055),
          labelStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontWeight: FontWeight.w800),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.13)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.mint, width: 1.3),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        chipTheme: ChipThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.panelSoft,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 72,
          backgroundColor: AppColors.nav,
          indicatorColor: AppColors.tealMist,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: const TextScaler.linear(1)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
    );
  }
}

class AppColors {
  static const canvas = Color(0xFF050B0F);
  static const canvasDeep = Color(0xFF020608);
  static const nav = Color(0xFF071319);
  static const panel = Color(0xFF0D1A22);
  static const panelSoft = Color(0xFF13242C);
  static const elevated = Color(0xFF172A32);
  static const indigo = Color(0xFF17254A);
  static const teal = Color(0xFF079AA3);
  static const tealDeep = Color(0xFF00636A);
  static const tealMist = Color(0x3325D7E0);
  static const mint = Color(0xFF8FF3F4);
  static const lime = Color(0xFFBEE66F);
  static const coral = Color(0xFFFF866D);
  static const yellow = Color(0xFFFFD166);
  static const text = Color(0xFFF4FAFA);
  static const muted = Color(0xFFA7B6B9);
  static const line = Color(0x1FFFFFFF);
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _signedIn = false;
  AppRole? _role;

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) {
      return LoginScreen(onSuccess: () => setState(() => _signedIn = true));
    }
    if (_role == null) {
      return RoleSelectionScreen(
          onSelected: (role) => setState(() => _role = role));
    }
    return switch (_role!) {
      AppRole.operator => const TeCaiGoShell(),
      AppRole.client => const ClientShell(),
      AppRole.business => const TouristBusinessShell(),
      AppRole.transport => const TransportProviderShell(),
    };
  }
}

enum AppRole { operator, client, business, transport }

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.onSelected});

  final ValueChanged<AppRole> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
              children: [
                const TeCaiGoLogo(size: 42, centered: true),
                const SizedBox(height: 30),
                const Text(
                  'Elige tu experiencia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontSize: 24,
                    height: 1.06,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Puedes operar experiencias, vender, transportar o entrar como turista.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    decoration: TextDecoration.none,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                RoleCard(
                  icon: Icons.explore_rounded,
                  title: 'Turista',
                  subtitle:
                      'Explora, reserva y compra experiencias turisticas.',
                  color: AppColors.yellow,
                  highlighted: true,
                  onTap: () => onSelected(AppRole.client),
                ),
                const SizedBox(height: 12),
                RoleCard(
                  icon: Icons.storefront_rounded,
                  title: 'Comercio turistico',
                  subtitle:
                      'Publica instalaciones, menu, capacidad y ubicacion.',
                  color: AppColors.lime,
                  onTap: () => onSelected(AppRole.business),
                ),
                const SizedBox(height: 12),
                RoleCard(
                  icon: Icons.airport_shuttle_rounded,
                  title: 'Transportista',
                  subtitle:
                      'Gestiona flota, mantenimiento y asignaciones de rutas.',
                  color: Color(0xFF65C7F7),
                  onTap: () => onSelected(AppRole.transport),
                ),
                const SizedBox(height: 12),
                RoleCard(
                  icon: Icons.route_rounded,
                  title: 'Tour operador',
                  subtitle: 'Gestiona radar, eventos, cupos y validaciones.',
                  color: AppColors.mint,
                  onTap: () => onSelected(AppRole.operator),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: highlighted
                ? [
                    color.withValues(alpha: 0.24),
                    AppColors.panelSoft.withValues(alpha: 0.92),
                    AppColors.canvas.withValues(alpha: 0.9),
                  ]
                : [
                    AppColors.panelSoft.withValues(alpha: 0.94),
                    AppColors.panel.withValues(alpha: 0.88),
                    AppColors.canvas.withValues(alpha: 0.82),
                  ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: highlighted
                ? color.withValues(alpha: 0.46)
                : Colors.white.withValues(alpha: 0.105),
          ),
          boxShadow: [
            BoxShadow(
              color: highlighted
                  ? color.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            IconBadge(icon: icon, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      decoration: TextDecoration.none,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mint),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'operador@tecaigo.com');
  final _password = TextEditingController(text: 'TecaiGO2026');
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    HapticFeedback.lightImpact();
    final validEmail =
        _email.text.trim().toLowerCase() == 'operador@tecaigo.com';
    final validPassword = _password.text == 'TecaiGO2026';
    if (validEmail && validPassword) {
      widget.onSuccess();
    } else {
      setState(() => _error = 'Revisa usuario o clave.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF06171D), AppColors.canvas],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 56),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TeCaiGoLogo(size: 62, centered: true),
                      const SizedBox(height: 10),
                      Text(
                        'Turismo conectado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.64),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _LoginSignalStrip(),
                      const SizedBox(height: 14),
                      PremiumSurface(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Eyebrow('ACCESO OPERADOR'),
                            const SizedBox(height: 8),
                            const Text(
                              'Opera turismo como una red viva',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 28,
                                height: 1.03,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Detecta demanda, arma experiencias y coordina aliados desde una interfaz pensada para campo.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.62),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 22),
                            AppTextField(
                              label: 'Usuario',
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              label: 'Contrasena',
                              controller: _password,
                              obscureText: true,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: _error == null
                                  ? const SizedBox(height: 20)
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: AppColors.coral,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: AppColors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Entrar a TeCaiGO',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _LoginHint(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginSignalStrip extends StatelessWidget {
  const _LoginSignalStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
            child:
                _SignalPill(icon: Icons.radar_rounded, label: 'Radar activo')),
        SizedBox(width: 10),
        Expanded(
            child: _SignalPill(
                icon: Icons.verified_rounded, label: 'Clusters verificados')),
      ],
    );
  }
}

class _SignalPill extends StatelessWidget {
  const _SignalPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.mint, size: 16),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHint extends StatelessWidget {
  const _LoginHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        'Demo: operador@tecaigo.com / TecaiGO2026',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.52),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _tab = 0;
  final List<ClientReservation> _reservations = [];

  void _openEvent(ClientEvent event) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientEventDetailSheet(
        event: event,
        onReserve: () {
          Navigator.pop(context);
          _editReservation(event: event);
        },
        onBuy: () {
          Navigator.pop(context);
          _editReservation(event: event, purchaseMode: true);
        },
      ),
    );
  }

  void _editReservation(
      {required ClientEvent event,
      ClientReservation? reservation,
      bool purchaseMode = false}) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientReservationEditorSheet(
        event: event,
        reservation: reservation,
        purchaseMode: purchaseMode,
        onSave: (updated) {
          setState(() {
            final index =
                _reservations.indexWhere((item) => item.id == updated.id);
            if (index >= 0) {
              _reservations[index] = updated;
            } else {
              _reservations.insert(0, updated);
            }
            _tab = 2;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(purchaseMode
                    ? 'Compra de ${event.title} iniciada.'
                    : '${event.title} reservado.')),
          );
        },
      ),
    );
  }

  void _openBusiness(TouristBusiness business) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BusinessDetailSheet(
        business: business,
        onReserve: () {
          Navigator.pop(context);
          _startBusinessCheckout(business: business, mode: 'Reserva');
        },
        onBuy: () {
          Navigator.pop(context);
          _startBusinessCheckout(business: business, mode: 'Compra');
        },
      ),
    );
  }

  void _startBusinessCheckout(
      {required TouristBusiness business, required String mode}) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BusinessCheckoutSheet(
        business: business,
        mode: mode,
        onDone: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$mode enviada para ${business.name}.')),
          );
        },
      ),
    );
  }

  void _cancelReservation(ClientReservation reservation) {
    HapticFeedback.mediumImpact();
    setState(
        () => _reservations.removeWhere((item) => item.id == reservation.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Reserva de ${reservation.event.title} cancelada.')),
    );
  }

  void _buyPromotion(PromotionDeal deal) {
    HapticFeedback.selectionClick();
    final promoEvent = ClientEvent(
      title: deal.title,
      subtitle: deal.subtitle,
      category: deal.channel,
      badge: deal.discount,
      imageUrl: deal.imageUrl,
      location: 'Promocion TeCaiGO',
      date: 'Promo activa',
      dateOptions: const ['Promo activa'],
      price: deal.price.replaceFirst('Desde ', ''),
      color: deal.color,
    );
    setState(() {
      _reservations.insert(
        0,
        ClientReservation(
          id: 'promo-${DateTime.now().millisecondsSinceEpoch}',
          event: promoEvent,
          guests: 1,
          selectedDate: 'Promo activa',
          contact: 'Compra desde promociones',
          note: '${deal.oldPrice} -> ${deal.price}',
          status: 'Compra promocional',
        ),
      );
      _tab = 2;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compra promocional de ${deal.title} iniciada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ClientDiscoverScreen(
          onEventOpened: _openEvent,
          onBusinessOpen: _openBusiness,
          onReserve: (event) => _editReservation(event: event),
          onBuy: (event) => _editReservation(event: event, purchaseMode: true)),
      ClientCommerceScreen(
        onBusinessOpen: _openBusiness,
        onPromotionBuy: _buyPromotion,
      ),
      ClientReservationsScreen(
        reservations: _reservations,
        onExplore: () => setState(() => _tab = 0),
        onEdit: (reservation) => _editReservation(
            event: reservation.event, reservation: reservation),
        onCancel: _cancelReservation,
      ),
      const ClientProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _tab = index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explorar',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer_rounded),
            label: 'Promociones',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _reservations.isNotEmpty,
              label: Text('${_reservations.length}'),
              child: const Icon(Icons.confirmation_number_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _reservations.isNotEmpty,
              label: Text('${_reservations.length}'),
              child: const Icon(Icons.confirmation_number_rounded),
            ),
            label: 'Reservas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class ClientDiscoverScreen extends StatefulWidget {
  const ClientDiscoverScreen({
    super.key,
    required this.onEventOpened,
    required this.onBusinessOpen,
    required this.onReserve,
    required this.onBuy,
  });

  final ValueChanged<ClientEvent> onEventOpened;
  final ValueChanged<TouristBusiness> onBusinessOpen;
  final ValueChanged<ClientEvent> onReserve;
  final ValueChanged<ClientEvent> onBuy;

  @override
  State<ClientDiscoverScreen> createState() => _ClientDiscoverScreenState();
}

class _ClientDiscoverScreenState extends State<ClientDiscoverScreen> {
  ClientExploreChannel _channel = ClientExploreChannel.events;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  void _setChannel(ClientExploreChannel channel) {
    setState(() {
      _channel = channel;
      _search.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Explorar',
            subtitle:
                'Eventos, agencias, boletos y aliados para comprar turismo.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: SalesEngineStrip(
              selected: _channel,
              onChanged: _setChannel,
            ),
          ),
          ChannelSearchField(
            controller: _search,
            hint: _searchHint,
            onChanged: (_) => setState(() {}),
            onClear: () => setState(() => _search.clear()),
          ),
          const SizedBox(height: 14),
          ..._channelContent(context),
          const SizedBox(height: 96),
        ],
      ),
    );
  }

  String get _normalizedQuery => _search.text.trim().toLowerCase();

  String get _searchHint {
    return switch (_channel) {
      ClientExploreChannel.events => 'Buscar evento, destino o tour operador',
      ClientExploreChannel.ticketing => 'Buscar concierto, museo o entrada',
      ClientExploreChannel.agencies => 'Buscar agencia, pais o paquete',
      ClientExploreChannel.allies => 'Buscar hostal, restaurante o comercio',
    };
  }

  List<Widget> _channelContent(BuildContext context) {
    return switch (_channel) {
      ClientExploreChannel.events => _eventWidgets(),
      ClientExploreChannel.ticketing => _productWidgets(
          title: 'Boleteria',
          subtitle: 'Conciertos, museos, pases y entradas con QR',
          products: ticketProducts,
        ),
      ClientExploreChannel.agencies => _productWidgets(
          title: 'Agencias de viaje',
          subtitle: 'Ataco, El Tunco, Rio Dulce y Semuc con rutas armadas',
          products: agencyProducts,
        ),
      ClientExploreChannel.allies => _businessWidgets(),
    };
  }

  List<Widget> _eventWidgets() {
    final visible = _normalizedQuery.isEmpty
        ? clientEvents
        : clientEvents
            .where((event) =>
                event.title.toLowerCase().contains(_normalizedQuery) ||
                event.subtitle.toLowerCase().contains(_normalizedQuery) ||
                event.category.toLowerCase().contains(_normalizedQuery) ||
                event.location.toLowerCase().contains(_normalizedQuery))
            .toList();
    return [
      if (visible.isEmpty)
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, 14),
          child: EmptySearchCard(),
        )
      else
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final event = visible[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FeaturedClientEventCard(
                  event: event,
                  onOpen: () => widget.onEventOpened(event),
                  onReserve: () => widget.onReserve(event),
                  onBuy: () => widget.onBuy(event),
                ),
              );
            },
          ),
        ),
      const SizedBox(height: 18),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: SectionTitle(
          title: 'Eventos de tour operadores',
          subtitle: 'Experiencias creadas por anfitriones y clusters',
        ),
      ),
      const SizedBox(height: 10),
      ...visible.map(
        (event) => Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          child: ClientEventCard(
            event: event,
            onOpen: () => widget.onEventOpened(event),
            onReserve: () => widget.onReserve(event),
            onBuy: () => widget.onBuy(event),
          ),
        ),
      ),
    ];
  }

  List<Widget> _productWidgets({
    required String title,
    required String subtitle,
    required List<SalesProduct> products,
  }) {
    final visible = _normalizedQuery.isEmpty
        ? products
        : products
            .where((product) =>
                product.title.toLowerCase().contains(_normalizedQuery) ||
                product.subtitle.toLowerCase().contains(_normalizedQuery) ||
                product.kind.toLowerCase().contains(_normalizedQuery) ||
                product.price.toLowerCase().contains(_normalizedQuery))
            .toList();
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SectionTitle(title: title, subtitle: subtitle),
      ),
      const SizedBox(height: 10),
      if (visible.isEmpty)
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, 14),
          child: EmptySearchCard(),
        )
      else
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SalesProductCard(
              product: visible[index],
              onOpen: () => showSalesProductSheet(context, visible[index]),
            ),
          ),
        ),
      const SizedBox(height: 18),
      ...visible.map(
        (product) => Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          child: SalesProductListTile(
            product: product,
            onOpen: () => showSalesProductSheet(context, product),
          ),
        ),
      ),
    ];
  }

  List<Widget> _businessWidgets() {
    final businesses = touristBusinesses
        .where((item) => ![
              'Boleteria',
              'Vuelos',
              'Paquetes',
              'Conciertos',
              'Agencia',
              'Tour'
            ].contains(item.category))
        .toList();
    final visible = _normalizedQuery.isEmpty
        ? businesses
        : businesses
            .where((business) =>
                business.name.toLowerCase().contains(_normalizedQuery) ||
                business.category.toLowerCase().contains(_normalizedQuery) ||
                business.subtitle.toLowerCase().contains(_normalizedQuery))
            .toList();
    return [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: SectionTitle(
          title: 'Aliados turisticos',
          subtitle: 'Hostales, restaurantes, transporte y comercios de apoyo',
        ),
      ),
      const SizedBox(height: 10),
      if (visible.isEmpty)
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 0, 18, 14),
          child: EmptySearchCard(),
        )
      else
        ...visible.map(
          (business) => Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: TouristBusinessCard(
              business: business,
              onOpen: () => widget.onBusinessOpen(business),
            ),
          ),
        ),
    ];
  }
}

class FeaturedClientEventCard extends StatelessWidget {
  const FeaturedClientEventCard({
    super.key,
    required this.event,
    required this.onOpen,
    required this.onReserve,
    required this.onBuy,
  });

  final ClientEvent event;
  final VoidCallback onOpen;
  final VoidCallback onReserve;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TecaigoImage(src: event.imageUrl, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22000000), Color(0xEE000000)],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(text: event.badge, color: event.color),
                  const SizedBox(height: 8),
                  Text(event.title,
                      style: const TextStyle(
                          fontSize: 26,
                          height: 1.02,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(event.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.28)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: GhostStat(
                              icon: Icons.place_outlined,
                              label: event.location)),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: onBuy,
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: Text(event.price),
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            foregroundColor: AppColors.canvasDeep),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChannelSearchField extends StatelessWidget {
  const ChannelSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.72), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w800,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: controller.text.isEmpty ? null : onClear,
              icon: Icon(
                controller.text.isEmpty
                    ? Icons.tune_rounded
                    : Icons.close_rounded,
                color: AppColors.mint,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ClientExploreChannel { events, ticketing, agencies, allies }

class SalesEngineStrip extends StatelessWidget {
  const SalesEngineStrip({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ClientExploreChannel selected;
  final ValueChanged<ClientExploreChannel> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      const _SalesEngineItem(ClientExploreChannel.events, 'Eventos',
          Icons.confirmation_number_rounded, AppColors.mint),
      const _SalesEngineItem(ClientExploreChannel.ticketing, 'Boleteria',
          Icons.local_activity_rounded, AppColors.yellow),
      const _SalesEngineItem(ClientExploreChannel.agencies, 'Agencias',
          Icons.flight_takeoff_rounded, Color(0xFF65C7F7)),
      const _SalesEngineItem(ClientExploreChannel.allies, 'Aliados',
          Icons.storefront_rounded, AppColors.lime),
    ];
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: item == items.last ? 0 : 8),
                child: InkWell(
                  onTap: () => onChanged(item.channel),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected == item.channel
                          ? item.color.withValues(alpha: 0.16)
                          : Colors.white.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected == item.channel
                            ? item.color.withValues(alpha: 0.58)
                            : Colors.white.withValues(alpha: 0.13),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(item.icon, color: item.color, size: 22),
                        const SizedBox(height: 7),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: selected == item.channel
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.72),
                              fontSize: 11,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SalesEngineItem {
  const _SalesEngineItem(this.channel, this.label, this.icon, this.color);

  final ClientExploreChannel channel;
  final String label;
  final IconData icon;
  final Color color;
}

class SalesProductCard extends StatelessWidget {
  const SalesProductCard({
    super.key,
    required this.product,
    required this.onOpen,
  });

  final SalesProduct product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: PremiumSurface(
          padding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TecaigoImage(src: product.imageUrl, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x05000000), Color(0xE9000000)],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: StatusPill(text: product.kind, color: product.color),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black.withValues(alpha: 0.42),
                  child: Icon(_salesProductIcon(product.kind),
                      color: product.color, size: 19),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                          height: 1.22),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                            child: Text(product.price,
                                style: TextStyle(
                                    color: product.color,
                                    fontWeight: FontWeight.w900))),
                        const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.mint, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SalesProductListTile extends StatelessWidget {
  const SalesProductListTile({
    super.key,
    required this.product,
    required this.onOpen,
  });

  final SalesProduct product;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: PremiumSurface(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: TecaigoImage(
                  src: product.imageUrl,
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(text: product.kind, color: product.color),
                  const SizedBox(height: 8),
                  Text(product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(product.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          height: 1.25)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_salesProductIcon(product.kind),
                          color: product.color, size: 17),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(product.price,
                            style: TextStyle(
                                color: product.color,
                                fontWeight: FontWeight.w900)),
                      ),
                      TextButton(onPressed: onOpen, child: const Text('Ver')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _salesProductIcon(String kind) {
  return switch (kind) {
    'Vuelo' => Icons.flight_takeoff_rounded,
    'Paquete' => Icons.card_travel_rounded,
    'Concierto' => Icons.music_note_rounded,
    'Museo' => Icons.account_balance_rounded,
    'Agencia' => Icons.support_agent_rounded,
    _ => Icons.local_activity_rounded,
  };
}

class CompactBusinessCard extends StatelessWidget {
  const CompactBusinessCard({super.key, required this.business});

  final TouristBusiness business;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TecaigoImage(src: business.imageUrl, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x08000000), Color(0xDD000000)],
                ),
              ),
            ),
            Positioned(
                left: 12,
                top: 12,
                child:
                    StatusPill(text: business.category, color: business.color)),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    business.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: business.color, size: 17),
                      const SizedBox(width: 4),
                      Text(business.rating,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientEventCard extends StatelessWidget {
  const ClientEventCard({
    super.key,
    required this.event,
    required this.onOpen,
    required this.onReserve,
    required this.onBuy,
  });

  final ClientEvent event;
  final VoidCallback onOpen;
  final VoidCallback onReserve;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: event.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x11000000), Color(0xCC000000)],
                      ),
                    ),
                  ),
                  Positioned(
                      left: 14,
                      top: 14,
                      child:
                          StatusPill(text: event.category, color: event.color)),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Text(event.title,
                        style: const TextStyle(
                            fontSize: 23,
                            height: 1.04,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.35)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: GhostStat(
                              icon: Icons.schedule_rounded, label: event.date)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: GhostStat(
                              icon: Icons.payments_outlined,
                              label: event.price)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReserve,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: const Text('Reservar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onBuy,
                          icon:
                              const Icon(Icons.shopping_cart_checkout_rounded),
                          label: const Text('Comprar'),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.mint,
                              foregroundColor: AppColors.canvasDeep),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientCommerceScreen extends StatefulWidget {
  const ClientCommerceScreen({
    super.key,
    required this.onBusinessOpen,
    required this.onPromotionBuy,
  });

  final ValueChanged<TouristBusiness> onBusinessOpen;
  final ValueChanged<PromotionDeal> onPromotionBuy;

  @override
  State<ClientCommerceScreen> createState() => _ClientCommerceScreenState();
}

class _ClientCommerceScreenState extends State<ClientCommerceScreen> {
  String _category = 'Todas';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Todas',
      'Eventos',
      'Boleteria',
      'Agencias',
      'Aliados',
      'Conciertos',
    ];
    final query = _search.text.trim().toLowerCase();
    final byCategory = _category == 'Todas'
        ? promotionDeals
        : promotionDeals.where((item) => item.channel == _category).toList();
    final visible = query.isEmpty
        ? byCategory
        : byCategory
            .where((item) =>
                item.title.toLowerCase().contains(query) ||
                item.channel.toLowerCase().contains(query) ||
                item.subtitle.toLowerCase().contains(query))
            .toList();

    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Promociones',
            subtitle:
                'Ofertas activas de eventos, boletos, agencias y aliados.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.055),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.72), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        hintText: 'Buscar promocion, destino o comercio',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w800,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _search.text.isEmpty
                        ? null
                        : () => setState(() => _search.clear()),
                    icon: Icon(
                      _search.text.isEmpty
                          ? Icons.tune_rounded
                          : Icons.close_rounded,
                      color: AppColors.mint,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = categories[index];
                final selected = item == _category;
                return ChoiceChip(
                  selected: selected,
                  label: Text(item),
                  onSelected: (_) => setState(() => _category = item),
                  selectedColor: AppColors.mint,
                  labelStyle: TextStyle(
                      color: selected
                          ? AppColors.canvasDeep
                          : Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w900),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: EmptySearchCard(),
            )
          else
            ...visible.map((deal) => Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: PromotionDealCard(
                  deal: deal,
                  onBuy: () => widget.onPromotionBuy(deal),
                ))),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class ClientMarketplacePulse extends StatelessWidget {
  const ClientMarketplacePulse({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const IconBadge(
              icon: Icons.local_offer_rounded,
              color: AppColors.yellow,
              small: true),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Solo promociones',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Una mezcla de todo lo publicado con descuento activo.',
                    style: TextStyle(color: AppColors.muted, height: 1.25)),
              ],
            ),
          ),
          StatusPill(text: 'Promo', color: AppColors.yellow),
        ],
      ),
    );
  }
}

class PromotionDealCard extends StatelessWidget {
  const PromotionDealCard({super.key, required this.deal, required this.onBuy});

  final PromotionDeal deal;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showPromotionDealSheet(context, deal, onBuy: onBuy),
      borderRadius: BorderRadius.circular(18),
      child: PremiumSurface(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: TecaigoImage(
                  src: deal.imageUrl,
                  width: 108,
                  height: 108,
                  fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusPill(text: deal.channel, color: deal.color),
                      const Spacer(),
                      StatusPill(text: deal.discount, color: AppColors.yellow),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(deal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(deal.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          height: 1.25)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(deal.icon, color: deal.color, size: 17),
                      const SizedBox(width: 5),
                      Expanded(
                        child: PromotionPriceLabel(deal: deal),
                      ),
                      FilledButton.icon(
                        onPressed: onBuy,
                        icon: const Icon(Icons.shopping_cart_checkout_rounded,
                            size: 16),
                        label: const Text('Comprar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          foregroundColor: AppColors.canvasDeep,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PromotionPriceLabel extends StatelessWidget {
  const PromotionPriceLabel({super.key, required this.deal});

  final PromotionDeal deal;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          deal.oldPrice,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.46),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.white.withValues(alpha: 0.55),
            decorationThickness: 2,
          ),
        ),
        Text(
          deal.price,
          style: TextStyle(color: deal.color, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class PromotionPricePanel extends StatelessWidget {
  const PromotionPricePanel({super.key, required this.deal});

  final PromotionDeal deal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, color: deal.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.oldPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.46),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.white.withValues(alpha: 0.55),
                    decorationThickness: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  deal.price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: deal.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showPromotionDealSheet(BuildContext context, PromotionDeal deal,
    {required VoidCallback onBuy}) {
  showAppSheet(
    context,
    PromotionDealSheet(deal: deal, onBuy: onBuy),
  );
}

class PromotionDealSheet extends StatelessWidget {
  const PromotionDealSheet(
      {super.key, required this.deal, required this.onBuy});

  final PromotionDeal deal;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1.55,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TecaigoImage(src: deal.imageUrl, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Color(0xEE000000)],
                    ),
                  ),
                ),
                Positioned(
                    left: 14,
                    top: 14,
                    child: StatusPill(text: deal.channel, color: deal.color)),
                Positioned(
                    right: 14,
                    top: 14,
                    child: StatusPill(
                        text: deal.discount, color: AppColors.yellow)),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 26,
                          height: 1.02,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          deal.subtitle,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.32,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: PromotionPricePanel(deal: deal)),
            const SizedBox(width: 10),
            Expanded(
                child: GhostStat(
                    icon: Icons.verified_outlined, label: 'Promocion')),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onBuy();
          },
          icon: const Icon(Icons.shopping_cart_checkout_rounded),
          label: const Text('Comprar promocion'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class EmptySearchCard extends StatelessWidget {
  const EmptySearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const IconBadge(
              icon: Icons.search_off_rounded, color: AppColors.yellow),
          const SizedBox(height: 12),
          const Text('No encontramos resultados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            'Prueba con agencia, boleto, hostal, tour o transporte.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62), height: 1.3),
          ),
        ],
      ),
    );
  }
}

class AvailabilityChip extends StatelessWidget {
  const AvailabilityChip({super.key, required this.date, required this.color});

  final String date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_rounded, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            date,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class TouristBusinessCard extends StatelessWidget {
  const TouristBusinessCard(
      {super.key, required this.business, required this.onOpen});

  final TouristBusiness business;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: PremiumSurface(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: TecaigoImage(
                  src: business.imageUrl,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(text: business.category, color: business.color),
                  const SizedBox(height: 8),
                  Text(business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(business.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          height: 1.25)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: business.color, size: 17),
                      const SizedBox(width: 4),
                      Text(business.rating,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      TextButton(onPressed: onOpen, child: const Text('Ver')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientReservationsScreen extends StatelessWidget {
  const ClientReservationsScreen({
    super.key,
    required this.reservations,
    required this.onExplore,
    required this.onEdit,
    required this.onCancel,
  });

  final List<ClientReservation> reservations;
  final VoidCallback onExplore;
  final ValueChanged<ClientReservation> onEdit;
  final ValueChanged<ClientReservation> onCancel;

  @override
  Widget build(BuildContext context) {
    final totalGuests =
        reservations.fold<int>(0, (sum, item) => sum + item.guests);
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
              title: 'Reservas',
              subtitle:
                  'Tus eventos comprados, apartados y pendientes de pago.'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: StatusBanner(
              icon: Icons.confirmation_number_outlined,
              title: reservations.isEmpty
                  ? 'Aun no tienes reservas'
                  : '${reservations.length} reservas activas',
              subtitle: reservations.isEmpty
                  ? 'Explora eventos y aparta cupos en pocos pasos.'
                  : '$totalGuests cupos organizados para tus proximas experiencias.',
              color: AppColors.mint,
            ),
          ),
          const SizedBox(height: 16),
          if (reservations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: PremiumSurface(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const IconBadge(
                        icon: Icons.travel_explore_rounded,
                        color: AppColors.yellow),
                    const SizedBox(height: 12),
                    const Text('Encuentra tu proximo plan',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(
                      'Guarda reservas, edita cantidad de personas y cancela si cambia tu itinerario.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.64),
                          height: 1.32),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: onExplore,
                      icon: const Icon(Icons.explore_rounded),
                      label: const Text('Explorar eventos'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          foregroundColor: AppColors.canvasDeep),
                    ),
                  ],
                ),
              ),
            )
          else
            ...reservations.map(
              (reservation) => Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: ClientReservationCard(
                  reservation: reservation,
                  onEdit: () => onEdit(reservation),
                  onCancel: () => onCancel(reservation),
                ),
              ),
            ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class ClientReservationCard extends StatelessWidget {
  const ClientReservationCard({
    super.key,
    required this.reservation,
    required this.onEdit,
    required this.onCancel,
  });

  final ClientReservation reservation;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final event = reservation.event;
    return PremiumSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TecaigoImage(src: event.imageUrl, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x11000000), Color(0xDD000000)],
                    ),
                  ),
                ),
                Positioned(
                    left: 14,
                    top: 14,
                    child: StatusPill(
                        text: reservation.status, color: event.color)),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Text(event.title,
                      style: const TextStyle(
                          fontSize: 23,
                          height: 1.04,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: GhostStat(
                            icon: Icons.group_outlined,
                            label: '${reservation.guests} cupos')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: GhostStat(
                            icon: Icons.payments_outlined,
                            label: reservation.totalLabel)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: GhostStat(
                            icon: Icons.schedule_rounded,
                            label: reservation.selectedDate)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: GhostStat(
                            icon: Icons.person_outline_rounded,
                            label: reservation.contact)),
                  ],
                ),
                if (reservation.note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      reservation.note,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.66),
                          height: 1.32),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            foregroundColor: AppColors.canvasDeep),
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
}

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
              title: 'Perfil',
              subtitle: 'Preferencias para personalizar tus recomendaciones.'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const IconBadge(
                      icon: Icons.person_rounded, color: AppColors.mint),
                  const SizedBox(height: 12),
                  const Text('Turista TeCaiGO',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('Playas, cafe, lago y experiencias familiares',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TouristBusinessShell extends StatefulWidget {
  const TouristBusinessShell({super.key});

  @override
  State<TouristBusinessShell> createState() => _TouristBusinessShellState();
}

class _TouristBusinessShellState extends State<TouristBusinessShell> {
  static const _businessStorageKey = 'tecaigo.businessProfiles.v1';

  int _tab = 0;
  bool _publishedClient = true;
  bool _publishedOperators = true;
  bool _acceptReservations = true;
  bool _instantConfirm = false;
  int _capacity = 80;
  int _tables = 18;
  int _rooms = 6;
  String _photo = 'assets/comercio/local_terraza.jpeg';
  late final List<BusinessGalleryPhoto> _galleryPhotos = [
    BusinessGalleryPhoto(
      id: 'local-terraza',
      src: _photo,
      label: 'Terraza',
    ),
    const BusinessGalleryPhoto(
      id: 'local-musica',
      src: 'assets/comercio/local_musica.jpeg',
      label: 'Ambiente',
    ),
    const BusinessGalleryPhoto(
      id: 'terraza-atardecer',
      src: 'assets/comercio/terraza_atardecer.jpeg',
      label: 'Vista',
    ),
  ];
  late List<BusinessPlaceProfile> _businessProfiles;
  late String _activeBusinessId;
  final _menuHighlight = TextEditingController(
      text: 'Parrillada de mariscos, salmon mediterraneo, sarten Pescaresc');

  BusinessPlaceProfile get _activeBusiness {
    return _businessProfiles.firstWhere(
      (business) => business.id == _activeBusinessId,
      orElse: () => _businessProfiles.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _businessProfiles = _loadBusinessProfiles();
    _activeBusinessId = _businessProfiles.first.id;
  }

  @override
  void dispose() {
    _menuHighlight.dispose();
    super.dispose();
  }

  List<BusinessPlaceProfile> _loadBusinessProfiles() {
    final stored = storageRead(_businessStorageKey);
    if (stored == null || stored.trim().isEmpty) {
      return [BusinessPlaceProfile.seed()];
    }
    try {
      final decoded = jsonDecode(stored) as List<dynamic>;
      final profiles = decoded
          .map((item) =>
              BusinessPlaceProfile.fromJson(item as Map<String, dynamic>))
          .toList();
      return profiles.isEmpty ? [BusinessPlaceProfile.seed()] : profiles;
    } catch (_) {
      return [BusinessPlaceProfile.seed()];
    }
  }

  void _persistBusinessProfiles() {
    storageWrite(
      _businessStorageKey,
      jsonEncode(_businessProfiles.map((item) => item.toJson()).toList()),
    );
  }

  void _saveBusinessProfile(BusinessPlaceProfile profile) {
    setState(() {
      final index =
          _businessProfiles.indexWhere((item) => item.id == profile.id);
      if (index >= 0) {
        _businessProfiles[index] = profile;
      } else {
        _businessProfiles.add(profile);
      }
      _activeBusinessId = profile.id;
      _persistBusinessProfiles();
    });
  }

  void _deleteBusinessProfile(BusinessPlaceProfile profile) {
    if (_businessProfiles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe quedar al menos un comercio.')),
      );
      return;
    }
    setState(() {
      _businessProfiles.removeWhere((item) => item.id == profile.id);
      if (_activeBusinessId == profile.id) {
        _activeBusinessId = _businessProfiles.first.id;
      }
      _persistBusinessProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeBusiness = _activeBusiness;
    final pages = [
      TouristBusinessDashboard(
        name: activeBusiness.name,
        category: activeBusiness.category,
        location: activeBusiness.location,
        photo: _photo,
        publishedClient: _publishedClient,
        publishedOperators: _publishedOperators,
      ),
      BusinessProfileCrudScreen(
        businesses: _businessProfiles,
        activeBusinessId: _activeBusinessId,
        photo: _photo,
        galleryPhotos: _galleryPhotos,
        onSelectBusiness: (business) =>
            setState(() => _activeBusinessId = business.id),
        onSaveBusiness: _saveBusinessProfile,
        onDeleteBusiness: _deleteBusinessProfile,
        onPhotoSelected: (value) => setState(() => _photo = value),
        onAddGalleryPhoto: () => setState(() {
          const options = [
            ('mariscos', 'assets/comercio/parrillada_mariscos.jpeg', 'Menu'),
            ('salmon', 'assets/comercio/salmon_mediterraneo.jpeg', 'Plato'),
            ('sarten', 'assets/comercio/pescaresc_sarten.jpeg', 'Especial'),
          ];
          final next = options[_galleryPhotos.length % options.length];
          _galleryPhotos.add(BusinessGalleryPhoto(
            id: '${next.$1}-${DateTime.now().microsecondsSinceEpoch}',
            src: next.$2,
            label: next.$3,
          ));
        }),
        onDeleteGalleryPhoto: (photo) => setState(() {
          _galleryPhotos.removeWhere((item) => item.id == photo.id);
          if (_photo == photo.src && _galleryPhotos.isNotEmpty) {
            _photo = _galleryPhotos.first.src;
          }
        }),
        onSetCoverPhoto: (photo) => setState(() => _photo = photo.src),
      ),
      TouristBusinessMenuScreen(
        menuHighlight: _menuHighlight,
        onChanged: () => setState(() {}),
      ),
      TouristBusinessCapacityScreen(
        capacity: _capacity,
        tables: _tables,
        rooms: _rooms,
        acceptReservations: _acceptReservations,
        instantConfirm: _instantConfirm,
        onCapacityChanged: (value) => setState(() => _capacity = value.round()),
        onTablesChanged: (value) => setState(() => _tables = value.round()),
        onRoomsChanged: (value) => setState(() => _rooms = value.round()),
        onAcceptReservations: (value) =>
            setState(() => _acceptReservations = value),
        onInstantConfirm: (value) => setState(() => _instantConfirm = value),
      ),
      TouristBusinessPublishScreen(
        publishedClient: _publishedClient,
        publishedOperators: _publishedOperators,
        acceptReservations: _acceptReservations,
        onClientChanged: (value) => setState(() => _publishedClient = value),
        onOperatorsChanged: (value) =>
            setState(() => _publishedOperators = value),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _tab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_location_alt_outlined),
            selectedIcon: Icon(Icons.edit_location_alt_rounded),
            label: 'Sedes',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_seat_outlined),
            selectedIcon: Icon(Icons.event_seat_rounded),
            label: 'Capacidad',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Publicar',
          ),
        ],
      ),
    );
  }
}

class TouristBusinessDashboard extends StatelessWidget {
  const TouristBusinessDashboard({
    super.key,
    required this.name,
    required this.category,
    required this.location,
    required this.photo,
    required this.publishedClient,
    required this.publishedOperators,
  });

  final String name;
  final String category;
  final String location;
  final String photo;
  final bool publishedClient;
  final bool publishedOperators;

  @override
  Widget build(BuildContext context) {
    final liveColor = publishedClient || publishedOperators
        ? AppColors.mint
        : AppColors.yellow;
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Homefeed comercial',
            subtitle:
                'Publicaciones de comercios y tour operadores dentro de TeCaiGO.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: BusinessComposerCard(
              name: name,
              category: category,
              location: location,
              photo: photo,
              statusColor: liveColor,
              publishedClient: publishedClient,
              publishedOperators: publishedOperators,
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: SectionTitle(
              title: 'Publicaciones activas',
              subtitle: 'Lo que ven turistas, operadores y aliados del cluster',
            ),
          ),
          const SizedBox(height: 10),
          const BusinessFeedPostCard(
            imageUrl: 'assets/comercio/terraza_atardecer.jpeg',
            badge: 'Comercio',
            title: 'Terraza Pescaresc',
            subtitle:
                'Ambiente de terraza, menu costero y espacio para grupos.',
            meta: 'Acepta reservas',
            icon: Icons.deck_rounded,
            color: AppColors.yellow,
            comments: [
              'Ruta Surf Tours: Tenemos salida el sabado, ¿pueden reservar 18 almuerzos con mariscos?',
              'TeCaiGO Tours: Interesa incluir la terraza como parada final del tour.',
              'Shuttle Centroam: Podemos coordinar transporte si confirman horario de cena.',
            ],
          ),
          BusinessFeedPostCard(
            imageUrl: photo,
            badge: 'Comercio',
            title: '$name disponible para grupos',
            subtitle:
                '$category en $location con capacidad, menu y reservas para rutas turisticas.',
            meta: publishedClient ? 'Publicado en turista' : 'Borrador',
            icon: Icons.storefront_rounded,
            color: AppColors.lime,
          ),
          const BusinessFeedPostCard(
            imageUrl: 'assets/comercio/local_musica.jpeg',
            badge: 'Tour operador',
            title: 'Noche con musica en vivo',
            subtitle:
                'Operador busca comercios con cena, ambiente y experiencia cultural.',
            meta: 'Solicita aliados',
            icon: Icons.route_rounded,
            color: AppColors.mint,
          ),
          const BusinessFeedPostCard(
            imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
            badge: 'Operadores',
            title: 'Rio Dulce necesita hospedaje',
            subtitle:
                'Salida publica con demanda activa para grupos familiares y fotografia.',
            meta: '8 cupos externos',
            icon: Icons.handshake_outlined,
            color: Color(0xFF65C7F7),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class BusinessComposerCard extends StatelessWidget {
  const BusinessComposerCard({
    super.key,
    required this.name,
    required this.category,
    required this.location,
    required this.photo,
    required this.statusColor,
    required this.publishedClient,
    required this.publishedOperators,
  });

  final String name;
  final String category;
  final String location;
  final String photo;
  final Color statusColor;
  final bool publishedClient;
  final bool publishedOperators;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showAppSheet(
        context,
        BusinessPublishSheet(
          name: name,
          category: category,
          location: location,
          photo: photo,
          statusColor: statusColor,
          publishedClient: publishedClient,
          publishedOperators: publishedOperators,
        ),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TecaigoImage(
                  src: photo, width: 46, height: 46, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  '¿Que publicamos?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessPublishSheet extends StatelessWidget {
  const BusinessPublishSheet({
    super.key,
    required this.name,
    required this.category,
    required this.location,
    required this.photo,
    required this.statusColor,
    required this.publishedClient,
    required this.publishedOperators,
  });

  final String name;
  final String category;
  final String location;
  final String photo;
  final Color statusColor;
  final bool publishedClient;
  final bool publishedOperators;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: TecaigoImage(
                  src: photo, width: 62, height: 62, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(
                      text: publishedClient || publishedOperators
                          ? 'Publicando'
                          : 'Borrador',
                      color: statusColor),
                  const SizedBox(height: 7),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text('$category - $location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        EventTextField(
          label: 'Describe tu publicacion',
          controller: TextEditingController(),
          icon: Icons.edit_note_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            PublishActionChip(
              icon: Icons.restaurant_menu_rounded,
              label: 'Menu',
              color: AppColors.yellow,
            ),
            PublishActionChip(
              icon: Icons.local_offer_outlined,
              label: 'Promocion',
              color: AppColors.lime,
            ),
            PublishActionChip(
              icon: Icons.event_available_outlined,
              label: 'Disponibilidad',
              color: AppColors.mint,
            ),
            PublishActionChip(
              icon: Icons.photo_library_outlined,
              label: 'Fotos',
              color: Color(0xFF65C7F7),
            ),
            PublishActionChip(
              icon: Icons.groups_2_outlined,
              label: 'Capacidad',
              color: AppColors.coral,
            ),
            PublishActionChip(
              icon: Icons.route_outlined,
              label: 'Operadores',
              color: AppColors.mint,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GhostStat(
                  icon: Icons.shopping_bag_outlined,
                  label: publishedClient ? 'Turistas' : 'Oculto'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GhostStat(
                  icon: Icons.route_outlined,
                  label: publishedOperators ? 'Operadores' : 'Oculto'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Publicacion preparada.')),
            );
          },
          icon: const Icon(Icons.send_rounded),
          label: const Text('Publicar en homefeed'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class PublishActionChip extends StatelessWidget {
  const PublishActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class BusinessFeedPostCard extends StatelessWidget {
  const BusinessFeedPostCard({
    super.key,
    required this.imageUrl,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
    required this.color,
    this.comments = const [],
  });

  final String imageUrl;
  final String badge;
  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;
  final Color color;
  final List<String> comments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.78,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x11000000), Color(0xDD000000)],
                      ),
                    ),
                  ),
                  Positioned(
                      left: 14,
                      top: 14,
                      child: StatusPill(text: badge, color: color)),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.black.withValues(alpha: 0.44),
                      child: Icon(icon, color: color, size: 22),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 24,
                            height: 1.04,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.32,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Te gusta $title')),
                            );
                          },
                          icon: const Icon(Icons.thumb_up_alt_outlined),
                          label: const Text('Me gusta'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => showAppSheet(
                            context,
                            BusinessCommentSheet(
                              imageUrl: imageUrl,
                              title: title,
                              subtitle: subtitle,
                              badge: badge,
                              color: color,
                              comments: comments,
                            ),
                          ),
                          icon: const Icon(Icons.mode_comment_outlined),
                          label: const Text('Comentar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            foregroundColor: AppColors.canvasDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (comments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => showAppSheet(
                        context,
                        BusinessCommentSheet(
                          imageUrl: imageUrl,
                          title: title,
                          subtitle: subtitle,
                          badge: badge,
                          color: color,
                          comments: comments,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                color: color, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                comments.first,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${comments.length}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BusinessCommentSheet extends StatelessWidget {
  const BusinessCommentSheet({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
    this.comments = const [],
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  final List<String> comments;

  @override
  Widget build(BuildContext context) {
    final comment = TextEditingController();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: TecaigoImage(
                  src: imageUrl, width: 72, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(text: badge, color: color),
                  const SizedBox(height: 8),
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                height: 1.28,
                fontWeight: FontWeight.w700)),
        if (comments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Comentarios',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...comments.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withValues(alpha: 0.18),
                      child: Icon(Icons.person_outline_rounded,
                          color: color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.74),
                              height: 1.25,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        EventTextField(
          label: 'Escribe un comentario',
          controller: comment,
          icon: Icons.chat_bubble_outline_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GhostStat(
                icon: Icons.storefront_outlined,
                label: 'Comercio',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GhostStat(
                icon: Icons.route_outlined,
                label: 'Operador',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Comentario enviado al feed.')),
            );
          },
          icon: const Icon(Icons.send_rounded),
          label: const Text('Enviar comentario'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class BusinessActionCard extends StatelessWidget {
  const BusinessActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, small: true),
          const SizedBox(width: 12),
          Expanded(child: SectionTitle(title: title, subtitle: subtitle)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.mint),
        ],
      ),
    );
  }
}

class TransportProviderShell extends StatefulWidget {
  const TransportProviderShell({super.key});

  @override
  State<TransportProviderShell> createState() => _TransportProviderShellState();
}

class _TransportProviderShellState extends State<TransportProviderShell> {
  static const _fleetStorageKey = 'tecaigo.transportFleet.v1';
  static const _transportPostsStorageKey = 'tecaigo.transportFeedPosts.v1';

  int _tab = 0;
  bool _availableOperators = true;
  bool _acceptUrgent = true;
  late List<TransportVehicle> _vehicles;
  late List<TransportFeedPost> _transportPosts;

  int get _vans => _vehicles.length;
  int get _drivers => _vehicles.map((vehicle) => vehicle.driver).toSet().length;
  int get _seats => _vehicles.fold(0, (sum, vehicle) => sum + vehicle.seats);

  @override
  void initState() {
    super.initState();
    _vehicles = _loadVehicles();
    _transportPosts = _loadTransportPosts();
  }

  List<TransportVehicle> _loadVehicles() {
    final stored = storageRead(_fleetStorageKey);
    if (stored == null || stored.trim().isEmpty) {
      return TransportVehicle.seedFleet();
    }
    try {
      final decoded = jsonDecode(stored) as List<dynamic>;
      final vehicles = decoded
          .map(
              (item) => TransportVehicle.fromJson(item as Map<String, dynamic>))
          .toList();
      return vehicles.isEmpty ? TransportVehicle.seedFleet() : vehicles;
    } catch (_) {
      return TransportVehicle.seedFleet();
    }
  }

  void _persistVehicles() {
    storageWrite(
      _fleetStorageKey,
      jsonEncode(_vehicles.map((vehicle) => vehicle.toJson()).toList()),
    );
  }

  void _saveVehicle(TransportVehicle vehicle) {
    setState(() {
      final index = _vehicles.indexWhere((item) => item.id == vehicle.id);
      if (index >= 0) {
        _vehicles[index] = vehicle;
      } else {
        _vehicles.add(vehicle);
      }
      _persistVehicles();
    });
  }

  void _deleteVehicle(TransportVehicle vehicle) {
    if (_vehicles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe quedar al menos una unidad.')),
      );
      return;
    }
    setState(() {
      _vehicles.removeWhere((item) => item.id == vehicle.id);
      _persistVehicles();
    });
  }

  List<TransportFeedPost> _loadTransportPosts() {
    final stored = storageRead(_transportPostsStorageKey);
    if (stored == null || stored.trim().isEmpty) {
      return TransportFeedPost.seedPosts();
    }
    try {
      final decoded = jsonDecode(stored) as List<dynamic>;
      final posts = decoded
          .map((item) =>
              TransportFeedPost.fromJson(item as Map<String, dynamic>))
          .toList();
      return posts.isEmpty ? TransportFeedPost.seedPosts() : posts;
    } catch (_) {
      return TransportFeedPost.seedPosts();
    }
  }

  void _persistTransportPosts() {
    storageWrite(
      _transportPostsStorageKey,
      jsonEncode(_transportPosts.map((post) => post.toJson()).toList()),
    );
  }

  void _saveTransportPost(TransportFeedPost post) {
    setState(() {
      final index = _transportPosts.indexWhere((item) => item.id == post.id);
      if (index >= 0) {
        _transportPosts[index] = post;
      } else {
        _transportPosts.insert(0, post);
      }
      _persistTransportPosts();
    });
  }

  void _deleteTransportPost(TransportFeedPost post) {
    if (_transportPosts.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe quedar al menos una publicacion.')),
      );
      return;
    }
    setState(() {
      _transportPosts.removeWhere((item) => item.id == post.id);
      _persistTransportPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TransportHomeFeedScreen(
        vans: _vans,
        drivers: _drivers,
        seats: _seats,
        availableOperators: _availableOperators,
        posts: _transportPosts,
        onSavePost: _saveTransportPost,
        onDeletePost: _deleteTransportPost,
      ),
      TransportAssignmentsScreen(
        acceptUrgent: _acceptUrgent,
        onUrgentChanged: (value) => setState(() => _acceptUrgent = value),
      ),
      const TransportCommitmentsScreen(),
      TransportFleetScreen(
        vehicles: _vehicles,
        onSaveVehicle: _saveVehicle,
        onDeleteVehicle: _deleteVehicle,
      ),
      TransportMaintenanceScreen(vehicles: _vehicles),
      TransportProfileScreen(
        availableOperators: _availableOperators,
        acceptUrgent: _acceptUrgent,
        onAvailableChanged: (value) =>
            setState(() => _availableOperators = value),
        onUrgentChanged: (value) => setState(() => _acceptUrgent = value),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _tab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'Rutas',
          ),
          NavigationDestination(
            icon: Icon(Icons.airport_shuttle_outlined),
            selectedIcon: Icon(Icons.airport_shuttle_rounded),
            label: 'Flota',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Mantto',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class TransportFeedPost {
  const TransportFeedPost({
    required this.id,
    required this.imageUrl,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.iconName,
    required this.colorValue,
  });

  final String id;
  final String imageUrl;
  final String badge;
  final String title;
  final String subtitle;
  final String meta;
  final String iconName;
  final int colorValue;

  IconData get icon {
    return switch (iconName) {
      'available' => Icons.airport_shuttle_rounded,
      'route' => Icons.route_rounded,
      _ => Icons.assignment_turned_in_outlined,
    };
  }

  Color get color => Color(colorValue);

  static List<TransportFeedPost> seedPosts() {
    return const [
      TransportFeedPost(
        id: 'pescaresc-microbus',
        imageUrl: 'assets/comercio/local_terraza.jpeg',
        badge: 'Solicitud',
        title: 'Terraza Pescaresc solicita microbus',
        subtitle:
            'Tour operador solicita transporte para 28 turistas, salida 6:00 a.m. hacia cena y musica en vivo.',
        meta: 'Pendiente',
        iconName: 'request',
        colorValue: 0xFF8FF3F4,
      ),
      TransportFeedPost(
        id: 'vans-costa',
        imageUrl: 'assets/turismo/el_tunco.jpeg',
        badge: 'Disponible',
        title: '2 vans libres para costa',
        subtitle:
            'Publicacion visible para operadores con rutas hacia El Tunco y La Libertad.',
        meta: 'Hoy',
        iconName: 'available',
        colorValue: 0xFF65C7F7,
      ),
      TransportFeedPost(
        id: 'musica-retorno',
        imageUrl: 'assets/comercio/local_musica.jpeg',
        badge: 'Ruta regional',
        title: 'Noche con musica requiere retorno',
        subtitle:
            'Asignacion sugerida por horario nocturno, pilotos disponibles y capacidad requerida.',
        meta: '18 pasajeros',
        iconName: 'route',
        colorValue: 0xFFFFD166,
      ),
    ];
  }

  factory TransportFeedPost.empty() {
    return TransportFeedPost(
      id: 'transport-post-${DateTime.now().microsecondsSinceEpoch}',
      imageUrl: 'assets/comercio/local_terraza.jpeg',
      badge: 'Disponible',
      title: '',
      subtitle: '',
      meta: 'Hoy',
      iconName: 'available',
      colorValue: 0xFF65C7F7,
    );
  }

  factory TransportFeedPost.fromJson(Map<String, dynamic> json) {
    return TransportFeedPost(
      id: (json['id'] as String?) ?? 'transport-post-fallback',
      imageUrl:
          (json['imageUrl'] as String?) ?? 'assets/comercio/local_terraza.jpeg',
      badge: (json['badge'] as String?) ?? 'Disponible',
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      meta: (json['meta'] as String?) ?? 'Hoy',
      iconName: (json['iconName'] as String?) ?? 'available',
      colorValue: (json['colorValue'] as num?)?.round() ?? 0xFF65C7F7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'badge': badge,
      'title': title,
      'subtitle': subtitle,
      'meta': meta,
      'iconName': iconName,
      'colorValue': colorValue,
    };
  }
}

class TransportHomeFeedScreen extends StatelessWidget {
  const TransportHomeFeedScreen({
    super.key,
    required this.vans,
    required this.drivers,
    required this.seats,
    required this.availableOperators,
    required this.posts,
    required this.onSavePost,
    required this.onDeletePost,
  });

  final int vans;
  final int drivers;
  final int seats;
  final bool availableOperators;
  final List<TransportFeedPost> posts;
  final ValueChanged<TransportFeedPost> onSavePost;
  final ValueChanged<TransportFeedPost> onDeletePost;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: TeCaiGoLogo(size: 28),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TransportComposerCard(
              vans: vans,
              drivers: drivers,
              seats: seats,
              availableOperators: availableOperators,
              onSavePost: onSavePost,
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: SectionTitle(
              title: 'Feed operativo',
              subtitle: 'Demanda de tours y disponibilidad publicada',
            ),
          ),
          const SizedBox(height: 10),
          ...posts.map(
            (post) => TransportFeedPostCard(
              post: post,
              onEdit: () => showAppSheet(
                context,
                TransportPublishSheet(
                  vans: vans,
                  drivers: drivers,
                  seats: seats,
                  availableOperators: availableOperators,
                  post: post,
                  onSavePost: onSavePost,
                ),
              ),
              onDelete: () => onDeletePost(post),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class TransportComposerCard extends StatelessWidget {
  const TransportComposerCard({
    super.key,
    required this.vans,
    required this.drivers,
    required this.seats,
    required this.availableOperators,
    required this.onSavePost,
  });

  final int vans;
  final int drivers;
  final int seats;
  final bool availableOperators;
  final ValueChanged<TransportFeedPost> onSavePost;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showAppSheet(
        context,
        TransportPublishSheet(
          vans: vans,
          drivers: drivers,
          seats: seats,
          availableOperators: availableOperators,
          post: TransportFeedPost.empty(),
          onSavePost: onSavePost,
        ),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const IconBadge(
                icon: Icons.airport_shuttle_rounded, color: Color(0xFF65C7F7)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  '¿Que publicamos?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransportPublishSheet extends StatefulWidget {
  const TransportPublishSheet({
    super.key,
    required this.vans,
    required this.drivers,
    required this.seats,
    required this.availableOperators,
    required this.post,
    required this.onSavePost,
  });

  final int vans;
  final int drivers;
  final int seats;
  final bool availableOperators;
  final TransportFeedPost post;
  final ValueChanged<TransportFeedPost> onSavePost;

  @override
  State<TransportPublishSheet> createState() => _TransportPublishSheetState();
}

class _TransportPublishSheetState extends State<TransportPublishSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.post.title);
  late final TextEditingController _subtitle =
      TextEditingController(text: widget.post.subtitle);
  late final TextEditingController _meta =
      TextEditingController(text: widget.post.meta);
  late String _badge = widget.post.badge;
  late String _image = widget.post.imageUrl;
  late String _iconName = widget.post.iconName;

  static const _imageOptions = [
    'assets/comercio/local_terraza.jpeg',
    'assets/comercio/local_musica.jpeg',
    'assets/turismo/el_tunco.jpeg',
    'assets/turismo/castillo_san_felipe.jpeg',
  ];

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _meta.dispose();
    super.dispose();
  }

  int get _colorValue {
    return switch (_badge) {
      'Solicitud' => 0xFF8FF3F4,
      'Ruta regional' => 0xFFFFD166,
      _ => 0xFF65C7F7,
    };
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega un titulo para publicar.')),
      );
      return;
    }
    widget.onSavePost(
      TransportFeedPost(
        id: widget.post.id,
        imageUrl: _image,
        badge: _badge,
        title: _title.text.trim(),
        subtitle: _subtitle.text.trim().isEmpty
            ? 'Publicacion operativa de transporte.'
            : _subtitle.text.trim(),
        meta: _meta.text.trim().isEmpty ? 'Hoy' : _meta.text.trim(),
        iconName: _iconName,
        colorValue: _colorValue,
      ),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publicacion guardada en el homefeed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        widget.availableOperators ? AppColors.mint : AppColors.yellow;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        Row(
          children: [
            const IconBadge(
                icon: Icons.airport_shuttle_rounded, color: Color(0xFF65C7F7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(
                      text: widget.availableOperators
                          ? 'Visible operadores'
                          : 'Fuera de linea',
                      color: statusColor),
                  const SizedBox(height: 7),
                  const Text('Shuttle Centroamerica',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.vans} unidades - ${widget.drivers} pilotos - ${widget.seats} asientos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        EventTextField(
          label: 'Titulo de publicacion',
          controller: _title,
          icon: Icons.title_rounded,
        ),
        const SizedBox(height: 12),
        EventTextField(
          label: 'Descripcion',
          controller: _subtitle,
          icon: Icons.edit_note_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        EventTextField(
          label: 'Estado corto',
          controller: _meta,
          icon: Icons.label_outline_rounded,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Solicitud', 'Disponible', 'Ruta regional'].map((badge) {
            final selected = _badge == badge;
            return ChoiceChip(
              selected: selected,
              label: Text(badge),
              onSelected: (_) => setState(() {
                _badge = badge;
                _iconName = switch (badge) {
                  'Solicitud' => 'request',
                  'Ruta regional' => 'route',
                  _ => 'available',
                };
              }),
              selectedColor: AppColors.tealMist,
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w900,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _imageOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final image = _imageOptions[index];
              final selected = _image == image;
              return InkWell(
                onTap: () => setState(() => _image = image),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 112,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? AppColors.mint
                          : Colors.white.withValues(alpha: 0.14),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: TecaigoImage(src: image, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.send_rounded),
          label: const Text('Publicar en homefeed'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class TransportFeedPostCard extends StatelessWidget {
  const TransportFeedPostCard({
    super.key,
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  final TransportFeedPost post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BusinessFeedPostCard(
          imageUrl: post.imageUrl,
          badge: post.badge,
          title: post.title,
          subtitle: post.subtitle,
          meta: post.meta,
          icon: post.icon,
          color: post.color,
        ),
        Positioned(
          top: 12,
          right: 30,
          child: Row(
            children: [
              _PhotoActionButton(
                tooltip: 'Editar publicacion',
                icon: Icons.edit_outlined,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _PhotoActionButton(
                tooltip: 'Eliminar publicacion',
                icon: Icons.delete_outline_rounded,
                onTap: onDelete,
                destructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TransportAssignmentsScreen extends StatefulWidget {
  const TransportAssignmentsScreen({
    super.key,
    required this.acceptUrgent,
    required this.onUrgentChanged,
  });

  final bool acceptUrgent;
  final ValueChanged<bool> onUrgentChanged;

  @override
  State<TransportAssignmentsScreen> createState() =>
      _TransportAssignmentsScreenState();
}

class _TransportAssignmentsScreenState
    extends State<TransportAssignmentsScreen> {
  String _source = 'Todas';

  static const _assignments = [
    TransportAssignmentData(
      source: 'Tour operadores',
      imageUrl: 'assets/turismo/ataco.jpeg',
      event: 'Ruta artesanal de Ataco',
      cluster: 'Cluster Ruta de las Flores',
      requester: 'Ataco Cafe Express',
      date: 'Sab 25 mayo - 6:00 a.m.',
      pax: '28 pasajeros',
      vehicle: 'Microbus con A/C',
      status: 'Pendiente',
      color: AppColors.mint,
    ),
    TransportAssignmentData(
      source: 'Tour operadores',
      imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
      event: 'Castillo de San Felipe',
      cluster: 'Cluster Rio Dulce',
      requester: 'Rio Dulce Tours',
      date: 'Dom 26 mayo - 4:30 a.m.',
      pax: '42 pasajeros',
      vehicle: 'Buseta regional',
      status: 'Cotizar',
      color: AppColors.yellow,
    ),
    TransportAssignmentData(
      source: 'Venta publica',
      imageUrl: null,
      event: 'El Tunco Beach Weekend',
      cluster: 'Cluster Costa Surf',
      requester: 'Reserva publica TeCaiGO',
      date: 'Dom 2 junio - 8:00 a.m.',
      pax: '16 pasajeros',
      vehicle: 'Van ejecutiva',
      status: 'Cotizar',
      color: AppColors.yellow,
    ),
    TransportAssignmentData(
      source: 'Venta publica',
      imageUrl: null,
      event: 'Cena en Terraza Pescaresc',
      cluster: 'Cluster Gastronomia Costera',
      requester: 'Venta directa TeCaiGO',
      date: 'Vie 7 junio - 6:30 p.m.',
      pax: '12 pasajeros',
      vehicle: 'Van privada',
      status: 'Cotizar',
      color: AppColors.yellow,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleAssignments = _source == 'Todas'
        ? _assignments
        : _assignments.where((item) => item.source == _source).toList();
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Solicitudes de transporte',
            subtitle:
                'Conexion directa con eventos creados por tour operadores.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: EventToggleRow(
              icon: Icons.bolt_rounded,
              title: 'Aceptar solicitudes urgentes',
              value: widget.acceptUrgent,
              onChanged: widget.onUrgentChanged,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TransportRequestSourceTabs(
              value: _source,
              onChanged: (value) => setState(() => _source = value),
            ),
          ),
          const SizedBox(height: 14),
          ...visibleAssignments.map(
            (assignment) => TransportAssignmentCard(assignment: assignment),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class TransportRequestSourceTabs extends StatelessWidget {
  const TransportRequestSourceTabs({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [
      ('Todas', 'Todas', Icons.event_available_outlined),
      ('Tour operadores', 'Operadores', Icons.route_outlined),
      ('Venta publica', 'Publico', Icons.confirmation_number_outlined),
    ];
    return Row(
      children: options.map((option) {
        final selected = value == option.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onChanged(option.$1),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 72,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.mint
                      : Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? AppColors.mint
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option.$3,
                      color: selected ? AppColors.canvasDeep : AppColors.mint,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      option.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? AppColors.canvasDeep
                            : Colors.white.withValues(alpha: 0.72),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TransportAssignmentData {
  const TransportAssignmentData({
    required this.source,
    required this.imageUrl,
    required this.event,
    required this.cluster,
    required this.requester,
    required this.date,
    required this.pax,
    required this.vehicle,
    required this.status,
    required this.color,
  });

  final String source;
  final String? imageUrl;
  final String event;
  final String cluster;
  final String requester;
  final String date;
  final String pax;
  final String vehicle;
  final String status;
  final Color color;
}

class TransportAssignmentCard extends StatelessWidget {
  const TransportAssignmentCard({
    super.key,
    required this.assignment,
  });

  final TransportAssignmentData assignment;

  @override
  Widget build(BuildContext context) {
    final isQuotation = assignment.imageUrl == null;
    if (isQuotation) {
      return TransportQuotationMessageCard(assignment: assignment);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: assignment.imageUrl!, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x11000000), Color(0xDD000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: StatusPill(
                      text: '${assignment.source} · ${assignment.requester}',
                      color: assignment.color,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      assignment.event,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.04,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          assignment.cluster,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      StatusPill(
                          text: assignment.status, color: assignment.color),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatusPill(
                    text: '${assignment.source} · ${assignment.requester}',
                    color: assignment.color,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                          icon: Icons.schedule_rounded,
                          label: assignment.date,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                          icon: Icons.groups_2_outlined,
                          label: assignment.pax,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GhostStat(
                          icon: Icons.airport_shuttle_outlined,
                          label: assignment.vehicle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Rechazar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${assignment.event} agregado a Rutas por cubrir.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Asignar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            foregroundColor: AppColors.canvasDeep,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransportQuotationMessageCard extends StatelessWidget {
  const TransportQuotationMessageCard({
    super.key,
    required this.assignment,
  });

  final TransportAssignmentData assignment;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransportQuotationDetailScreen(assignment: assignment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(28),
        child: PremiumSurface(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(
                    icon: Icons.mark_email_unread_outlined,
                    color: AppColors.yellow,
                    small: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                assignment.event,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  height: 1.08,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            StatusPill(
                              text: 'Cotizacion',
                              color: AppColors.yellow,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          assignment.cluster,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusPill(
                      text: '${assignment.source} · ${assignment.requester}',
                      color: AppColors.yellow,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Solicita precio de transporte para ${assignment.pax.toLowerCase()} usando ${assignment.vehicle.toLowerCase()}.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GhostStat(
                      icon: Icons.schedule_rounded,
                      label: assignment.date,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openDetail(context),
                      icon: const Icon(Icons.forum_outlined),
                      label: const Text('Abrir mensaje'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: () => _openDetail(context),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.mint,
                      foregroundColor: AppColors.canvasDeep,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransportQuotationDetailScreen extends StatelessWidget {
  const TransportQuotationDetailScreen({
    super.key,
    required this.assignment,
  });

  final TransportAssignmentData assignment;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppHeader(
            title: assignment.event,
            subtitle: 'Carta de cotizacion de transporte',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(
                        icon: Icons.mark_chat_unread_outlined,
                        color: AppColors.yellow,
                        small: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SectionTitle(
                          title: assignment.requester,
                          subtitle: assignment.cluster,
                        ),
                      ),
                      StatusPill(text: 'Pendiente', color: AppColors.yellow),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.055),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      'Hola, necesito cotizacion de transporte para ${assignment.event}. Somos ${assignment.pax.toLowerCase()}, fecha ${assignment.date.toLowerCase()}, preferimos ${assignment.vehicle.toLowerCase()}. Quedo pendiente del precio y disponibilidad.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                          icon: Icons.schedule_rounded,
                          label: assignment.date,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                          icon: Icons.groups_2_outlined,
                          label: assignment.pax,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GhostStat(
                          icon: Icons.airport_shuttle_outlined,
                          label: assignment.vehicle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Respuesta de cotizacion',
                    subtitle:
                        'Prepara precio, disponibilidad y canal de envio.',
                  ),
                  const SizedBox(height: 14),
                  const GhostStat(
                    icon: Icons.attach_money_rounded,
                    label: 'Precio sugerido: pendiente de confirmar',
                  ),
                  const SizedBox(height: 10),
                  const GhostStat(
                    icon: Icons.directions_bus_filled_outlined,
                    label: 'Unidad disponible: por seleccionar',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Conversacion abierta.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Chat'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Respuesta por WhatsApp lista.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone_in_talk_outlined),
                          label: const Text('WhatsApp'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cotizacion enviada para ${assignment.event}.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Enviar cotizacion'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: AppColors.canvasDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class TransportCommitmentsScreen extends StatefulWidget {
  const TransportCommitmentsScreen({super.key});

  @override
  State<TransportCommitmentsScreen> createState() =>
      _TransportCommitmentsScreenState();
}

class _TransportCommitmentsScreenState
    extends State<TransportCommitmentsScreen> {
  String _view = 'fecha';

  static const _commitments = [
    TransportCommitmentData(
      source: 'Tour operador',
      imageUrl: 'assets/turismo/ataco.jpeg',
      date: 'Sab 25 mayo',
      time: '6:00 a.m.',
      event: 'Ruta artesanal de Ataco',
      cluster: 'Cluster Ruta de las Flores',
      route: 'San Salvador - Ataco - Apaneca',
      unit: 'Microbus 02',
      driver: 'Ana Morales',
      pax: '28 pasajeros',
      status: 'Por cubrir',
      color: AppColors.mint,
    ),
    TransportCommitmentData(
      source: 'Tour operador',
      imageUrl: 'assets/turismo/el_tunco.jpeg',
      date: 'Dom 2 junio',
      time: '8:00 a.m.',
      event: 'El Tunco Beach Weekend',
      cluster: 'Cluster Costa Surf',
      route: 'Santa Tecla - El Tunco - La Libertad',
      unit: 'Van 01',
      driver: 'Carlos Mendez',
      pax: '16 pasajeros',
      status: 'Asignado',
      color: Color(0xFF65C7F7),
    ),
    TransportCommitmentData(
      source: 'Venta publica',
      imageUrl: null,
      date: 'Vie 7 junio',
      time: '6:30 p.m.',
      event: 'Cotizacion traslado privado',
      cluster: 'Solicitud directa TeCaiGO',
      route: 'Hotel zona rosa - Terraza Pescaresc - retorno',
      unit: 'Unidad por definir',
      driver: 'Piloto por asignar',
      pax: '12 pasajeros',
      status: 'Precio pendiente',
      color: AppColors.yellow,
    ),
  ];

  List<String> get _groups {
    final values = _commitments
        .map((commitment) {
          return switch (_view) {
            'ruta' => commitment.route,
            'flota' => commitment.unit,
            _ => commitment.date,
          };
        })
        .toSet()
        .toList();
    return values;
  }

  String _groupSubtitle(String group) {
    final items = _commitments.where((commitment) {
      return switch (_view) {
        'ruta' => commitment.route == group,
        'flota' => commitment.unit == group,
        _ => commitment.date == group,
      };
    }).toList();
    final seats = items.fold<int>(0, (sum, item) {
      return sum + (int.tryParse(item.pax.split(' ').first) ?? 0);
    });
    return '${items.length} compromiso${items.length == 1 ? '' : 's'} · $seats pasajeros';
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Rutas por cubrir',
            subtitle:
                'Compromisos aceptados con trazabilidad por fecha, flota y ruta.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: CommitmentViewButton(
                    selected: _view == 'fecha',
                    icon: Icons.calendar_month_outlined,
                    label: 'Por fecha',
                    onTap: () => setState(() => _view = 'fecha'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CommitmentViewButton(
                    selected: _view == 'ruta',
                    icon: Icons.route_outlined,
                    label: 'Por ruta',
                    onTap: () => setState(() => _view = 'ruta'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CommitmentViewButton(
                    selected: _view == 'flota',
                    icon: Icons.airport_shuttle_outlined,
                    label: 'Por flota',
                    onTap: () => setState(() => _view = 'flota'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._groups.expand((group) {
            final items = _commitments.where((commitment) {
              return switch (_view) {
                'ruta' => commitment.route == group,
                'flota' => commitment.unit == group,
                _ => commitment.date == group,
              };
            }).toList();
            return [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child:
                    SectionTitle(title: group, subtitle: _groupSubtitle(group)),
              ),
              ...items.map(
                (commitment) => TransportCommitmentCard(commitment: commitment),
              ),
            ];
          }),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class CommitmentViewButton extends StatelessWidget {
  const CommitmentViewButton({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.mint : Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.mint
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? AppColors.canvasDeep : AppColors.mint),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? AppColors.canvasDeep
                      : Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransportCommitmentData {
  const TransportCommitmentData({
    required this.source,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.event,
    required this.cluster,
    required this.route,
    required this.unit,
    required this.driver,
    required this.pax,
    required this.status,
    required this.color,
  });

  final String source;
  final String? imageUrl;
  final String date;
  final String time;
  final String event;
  final String cluster;
  final String route;
  final String unit;
  final String driver;
  final String pax;
  final String status;
  final Color color;
}

class TransportCommitmentCard extends StatelessWidget {
  const TransportCommitmentCard({super.key, required this.commitment});

  final TransportCommitmentData commitment;

  @override
  Widget build(BuildContext context) {
    final isQuotation = commitment.imageUrl == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (commitment.imageUrl != null)
              AspectRatio(
                aspectRatio: 1.9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TecaigoImage(src: commitment.imageUrl!, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x11000000), Color(0xDD000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: StatusPill(
                          text: commitment.source, color: commitment.color),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Text(
                        commitment.event,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.04,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.08),
                  border: Border(
                    bottom: BorderSide(
                        color: AppColors.yellow.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    IconBadge(
                        icon: Icons.request_quote_outlined,
                        color: AppColors.yellow,
                        small: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SectionTitle(
                        title: commitment.event,
                        subtitle: 'Sin imagen: solicitud privada de consumidor',
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (commitment.imageUrl == null) ...[
                        Expanded(
                          child: SectionTitle(
                            title: commitment.event,
                            subtitle: commitment.cluster,
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Text(
                            commitment.cluster,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.62),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      StatusPill(
                          text: commitment.status, color: commitment.color),
                    ],
                  ),
                  if (isQuotation) ...[
                    const SizedBox(height: 10),
                    const GhostStat(
                      icon: Icons.attach_money_rounded,
                      label: 'Esperando precio de transporte',
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                          icon: Icons.schedule_rounded,
                          label: '${commitment.date} - ${commitment.time}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GhostStat(
                      icon: Icons.alt_route_rounded, label: commitment.route),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                            icon: Icons.airport_shuttle_outlined,
                            label: commitment.unit),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GhostStat(
                            icon: Icons.person_outline_rounded,
                            label: commitment.driver),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GhostStat(
                      icon: Icons.groups_2_outlined, label: commitment.pax),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransportVehicle {
  const TransportVehicle({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.plate,
    required this.type,
    required this.driver,
    required this.seats,
    required this.coverage,
    required this.status,
    required this.nextService,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String plate;
  final String type;
  final String driver;
  final int seats;
  final String coverage;
  final String status;
  final String nextService;

  static List<TransportVehicle> seedFleet() {
    return const [
      TransportVehicle(
        id: 'van-01',
        name: 'Van 01',
        imageUrl: 'assets/transporte/van_01.jpeg',
        plate: 'P-702341',
        type: 'Hyundai H1',
        driver: 'Carlos Mendez',
        seats: 12,
        coverage: 'San Salvador, Ruta de las Flores y costa',
        status: 'Disponible',
        nextService: 'Frenos en 9 dias',
      ),
      TransportVehicle(
        id: 'microbus-02',
        name: 'Microbus 02',
        imageUrl: 'assets/transporte/microbus_02.jpeg',
        plate: 'MB-18422',
        type: 'Toyota Coaster',
        driver: 'Ana Morales',
        seats: 28,
        coverage: 'El Salvador, Guatemala y Honduras',
        status: 'Asignado',
        nextService: 'Aceite completado hoy',
      ),
      TransportVehicle(
        id: 'urvan-03',
        name: 'Van 03',
        imageUrl: 'assets/transporte/van_03.jpeg',
        plate: 'P-908174',
        type: 'Nissan Urvan',
        driver: 'Luis Portillo',
        seats: 15,
        coverage: 'Aeropuerto, hoteles y rutas privadas',
        status: 'Mantto',
        nextService: 'Revision preventiva',
      ),
    ];
  }

  factory TransportVehicle.empty() {
    return TransportVehicle(
      id: 'vehicle-${DateTime.now().microsecondsSinceEpoch}',
      name: '',
      imageUrl: 'assets/transporte/van_01.jpeg',
      plate: '',
      type: '',
      driver: '',
      seats: 12,
      coverage: '',
      status: 'Disponible',
      nextService: '',
    );
  }

  factory TransportVehicle.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?) ?? 'vehicle-fallback';
    final name = (json['name'] as String?) ?? '';
    return TransportVehicle(
      id: id,
      name: name,
      imageUrl: (json['imageUrl'] as String?) ?? imageFor(id, name),
      plate: (json['plate'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      driver: (json['driver'] as String?) ?? '',
      seats: (json['seats'] as num?)?.round() ?? 0,
      coverage: (json['coverage'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'Disponible',
      nextService: (json['nextService'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'plate': plate,
      'type': type,
      'driver': driver,
      'seats': seats,
      'coverage': coverage,
      'status': status,
      'nextService': nextService,
    };
  }

  static String imageFor(String id, String name) {
    final key = '$id $name'.toLowerCase();
    if (key.contains('microbus') || key.contains('coaster')) {
      return 'assets/transporte/microbus_02.jpeg';
    }
    if (key.contains('urvan') || key.contains('03')) {
      return 'assets/transporte/van_03.jpeg';
    }
    return 'assets/transporte/van_01.jpeg';
  }
}

class TransportFleetScreen extends StatelessWidget {
  const TransportFleetScreen({
    super.key,
    required this.vehicles,
    required this.onSaveVehicle,
    required this.onDeleteVehicle,
  });

  final List<TransportVehicle> vehicles;
  final ValueChanged<TransportVehicle> onSaveVehicle;
  final ValueChanged<TransportVehicle> onDeleteVehicle;

  void _openEditor(BuildContext context, TransportVehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransportVehicleFormScreen(
          vehicle: vehicle,
          onSaveVehicle: onSaveVehicle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Flota y unidades',
            subtitle: 'Administra cada vehiculo, piloto, cobertura y estado.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      _openEditor(context, TransportVehicle.empty()),
                  icon: const Icon(Icons.add_road_rounded),
                  label: const Text('Nueva unidad'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.canvasDeep,
                  ),
                ),
                const SizedBox(height: 14),
                ...vehicles.map(
                  (vehicle) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TransportVehicleCrudCard(
                      vehicle: vehicle,
                      canDelete: vehicles.length > 1,
                      onEdit: () => _openEditor(context, vehicle),
                      onDelete: () => onDeleteVehicle(vehicle),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class TransportVehicleCrudCard extends StatelessWidget {
  const TransportVehicleCrudCard({
    super.key,
    required this.vehicle,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  final TransportVehicle vehicle;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _statusColor {
    return switch (vehicle.status) {
      'Disponible' => AppColors.mint,
      'Asignado' => const Color(0xFF65C7F7),
      'Mantto' => AppColors.yellow,
      _ => AppColors.coral,
    };
  }

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.95,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TecaigoImage(src: vehicle.imageUrl, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x11000000), Color(0xDD000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: StatusPill(text: vehicle.status, color: _statusColor),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name.trim().isEmpty
                            ? 'Unidad sin nombre'
                            : vehicle.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.04,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${vehicle.type} · ${vehicle.plate}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GhostStat(
                          icon: Icons.event_seat_outlined,
                          label: '${vehicle.seats} asientos'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GhostStat(
                          icon: Icons.person_outline_rounded,
                          label: vehicle.driver.trim().isEmpty
                              ? 'Piloto pendiente'
                              : vehicle.driver),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GhostStat(
                  icon: Icons.map_outlined,
                  label: vehicle.coverage.trim().isEmpty
                      ? 'Cobertura pendiente'
                      : vehicle.coverage,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Gestionar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'Eliminar unidad',
                      onPressed: canDelete ? onDelete : null,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.coral),
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
}

class TransportVehicleFormScreen extends StatefulWidget {
  const TransportVehicleFormScreen({
    super.key,
    required this.vehicle,
    required this.onSaveVehicle,
  });

  final TransportVehicle vehicle;
  final ValueChanged<TransportVehicle> onSaveVehicle;

  @override
  State<TransportVehicleFormScreen> createState() =>
      _TransportVehicleFormScreenState();
}

class _TransportVehicleFormScreenState
    extends State<TransportVehicleFormScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.vehicle.name);
  late final TextEditingController _plate =
      TextEditingController(text: widget.vehicle.plate);
  late final TextEditingController _type =
      TextEditingController(text: widget.vehicle.type);
  late final TextEditingController _driver =
      TextEditingController(text: widget.vehicle.driver);
  late final TextEditingController _seats =
      TextEditingController(text: widget.vehicle.seats.toString());
  late final TextEditingController _coverage =
      TextEditingController(text: widget.vehicle.coverage);
  late final TextEditingController _nextService =
      TextEditingController(text: widget.vehicle.nextService);
  late String _status = widget.vehicle.status;

  @override
  void dispose() {
    _name.dispose();
    _plate.dispose();
    _type.dispose();
    _driver.dispose();
    _seats.dispose();
    _coverage.dispose();
    _nextService.dispose();
    super.dispose();
  }

  void _save() {
    final seats = int.tryParse(_seats.text.trim()) ?? 0;
    if (_name.text.trim().isEmpty || seats <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega nombre y asientos validos.')),
      );
      return;
    }
    widget.onSaveVehicle(
      TransportVehicle(
        id: widget.vehicle.id,
        name: _name.text.trim(),
        imageUrl: widget.vehicle.imageUrl,
        plate: _plate.text.trim(),
        type: _type.text.trim(),
        driver: _driver.text.trim(),
        seats: seats,
        coverage: _coverage.text.trim(),
        status: _status,
        nextService: _nextService.text.trim(),
      ),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unidad guardada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AppGradientScaffold(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            AppHeader(
              title: widget.vehicle.name.trim().isEmpty
                  ? 'Nueva unidad'
                  : 'Gestionar unidad',
              subtitle: 'Datos operativos para asignar transporte a tours.',
              trailing: IconButton.filledTonal(
                tooltip: 'Volver',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: PremiumSurface(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    EventTextField(
                        label: 'Nombre de unidad',
                        controller: _name,
                        icon: Icons.airport_shuttle_rounded),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Placa',
                        controller: _plate,
                        icon: Icons.confirmation_number_outlined),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Tipo / modelo',
                        controller: _type,
                        icon: Icons.directions_bus_filled_outlined),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Piloto asignado',
                        controller: _driver,
                        icon: Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Asientos',
                        controller: _seats,
                        icon: Icons.event_seat_outlined),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Cobertura',
                        controller: _coverage,
                        icon: Icons.map_outlined,
                        maxLines: 2),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Proximo mantenimiento',
                        controller: _nextService,
                        icon: Icons.build_outlined),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Disponible', 'Asignado', 'Mantto', 'Fuera']
                          .map((status) {
                        final selected = _status == status;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(status),
                          onSelected: (_) => setState(() => _status = status),
                          selectedColor: AppColors.tealMist,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar unidad'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.mint,
                        foregroundColor: AppColors.canvasDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class VehicleStatusCard extends StatelessWidget {
  const VehicleStatusCard({
    super.key,
    required this.name,
    required this.detail,
    required this.status,
    required this.color,
  });

  final String name;
  final String detail;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: PremiumSurface(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            IconBadge(
                icon: Icons.airport_shuttle_rounded, color: color, small: true),
            const SizedBox(width: 12),
            Expanded(child: SectionTitle(title: name, subtitle: detail)),
            StatusPill(text: status, color: color),
          ],
        ),
      ),
    );
  }
}

class TransportMaintenanceRecord {
  const TransportMaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.control,
    required this.category,
    required this.dueDate,
    required this.kilometers,
    required this.provider,
    required this.cost,
    required this.status,
    required this.notes,
  });

  final String id;
  final String vehicleId;
  final String control;
  final String category;
  final String dueDate;
  final String kilometers;
  final String provider;
  final String cost;
  final String status;
  final String notes;

  factory TransportMaintenanceRecord.empty(String vehicleId) {
    return TransportMaintenanceRecord(
      id: 'maintenance-${DateTime.now().microsecondsSinceEpoch}',
      vehicleId: vehicleId,
      control: '',
      category: 'Preventivo',
      dueDate: '',
      kilometers: '',
      provider: '',
      cost: '',
      status: 'Programado',
      notes: '',
    );
  }

  static List<TransportMaintenanceRecord> seed(
      List<TransportVehicle> vehicles) {
    String idAt(int index) => vehicles.isEmpty
        ? 'van-01'
        : vehicles[index.clamp(0, vehicles.length - 1)].id;
    return [
      TransportMaintenanceRecord(
        id: 'mantto-frenos-01',
        vehicleId: idAt(0),
        control: 'Revision frenos',
        category: 'Seguridad',
        dueDate: 'Vence en 9 dias',
        kilometers: '68,400 km',
        provider: 'Taller Ruta Segura',
        cost: r'$85',
        status: 'Proximo',
        notes: 'Bloquear asignaciones largas si no se completa.',
      ),
      TransportMaintenanceRecord(
        id: 'mantto-aceite-02',
        vehicleId: idAt(1),
        control: 'Cambio de aceite',
        category: 'Preventivo',
        dueDate: 'Completado hoy',
        kilometers: '74,120 km',
        provider: 'Lubricentro Central',
        cost: r'$42',
        status: 'Listo',
        notes: 'Filtro y aceite sintético registrados.',
      ),
      TransportMaintenanceRecord(
        id: 'mantto-permisos-03',
        vehicleId: idAt(2),
        control: 'Seguro y permisos',
        category: 'Documentacion',
        dueDate: 'Vigente hasta agosto',
        kilometers: '15 dias para revision',
        provider: 'Administracion interna',
        cost: r'$0',
        status: 'OK',
        notes: 'Permisos turísticos validados para operación.',
      ),
    ];
  }

  factory TransportMaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return TransportMaintenanceRecord(
      id: (json['id'] as String?) ?? 'maintenance-fallback',
      vehicleId: (json['vehicleId'] as String?) ?? 'van-01',
      control: (json['control'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'Preventivo',
      dueDate: (json['dueDate'] as String?) ?? '',
      kilometers: (json['kilometers'] as String?) ?? '',
      provider: (json['provider'] as String?) ?? '',
      cost: (json['cost'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'Programado',
      notes: (json['notes'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'control': control,
      'category': category,
      'dueDate': dueDate,
      'kilometers': kilometers,
      'provider': provider,
      'cost': cost,
      'status': status,
      'notes': notes,
    };
  }
}

class TransportMaintenanceScreen extends StatefulWidget {
  const TransportMaintenanceScreen({super.key, required this.vehicles});

  final List<TransportVehicle> vehicles;

  @override
  State<TransportMaintenanceScreen> createState() =>
      _TransportMaintenanceScreenState();
}

class _TransportMaintenanceScreenState
    extends State<TransportMaintenanceScreen> {
  static const _storageKey = 'tecaigo.transportMaintenance.v1';

  late List<TransportMaintenanceRecord> _records;
  String _vehicleFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _records = _loadRecords();
  }

  List<TransportMaintenanceRecord> _loadRecords() {
    final stored = storageRead(_storageKey);
    if (stored == null || stored.trim().isEmpty) {
      return TransportMaintenanceRecord.seed(widget.vehicles);
    }
    try {
      final decoded = jsonDecode(stored) as List<dynamic>;
      final records = decoded
          .map((item) =>
              TransportMaintenanceRecord.fromJson(item as Map<String, dynamic>))
          .toList();
      return records.isEmpty
          ? TransportMaintenanceRecord.seed(widget.vehicles)
          : records;
    } catch (_) {
      return TransportMaintenanceRecord.seed(widget.vehicles);
    }
  }

  void _persistRecords() {
    storageWrite(
      _storageKey,
      jsonEncode(_records.map((record) => record.toJson()).toList()),
    );
  }

  void _saveRecord(TransportMaintenanceRecord record) {
    setState(() {
      final index = _records.indexWhere((item) => item.id == record.id);
      if (index >= 0) {
        _records[index] = record;
      } else {
        _records.insert(0, record);
      }
      _persistRecords();
    });
  }

  void _deleteRecord(TransportMaintenanceRecord record) {
    setState(() {
      _records.removeWhere((item) => item.id == record.id);
      _persistRecords();
    });
  }

  TransportVehicle _vehicleFor(String id) {
    return widget.vehicles.firstWhere(
      (vehicle) => vehicle.id == id,
      orElse: () => widget.vehicles.isNotEmpty
          ? widget.vehicles.first
          : TransportVehicle.empty(),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'Listo' || 'OK' => AppColors.mint,
      'Proximo' || 'Programado' => AppColors.yellow,
      'Bloqueado' || 'Vencido' => AppColors.coral,
      _ => const Color(0xFF65C7F7),
    };
  }

  void _openEditor([TransportMaintenanceRecord? record]) {
    final vehicleId = _vehicleFilter == 'Todas'
        ? (widget.vehicles.isNotEmpty ? widget.vehicles.first.id : 'van-01')
        : _vehicleFilter;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransportMaintenanceFormScreen(
          vehicles: widget.vehicles,
          record: record ?? TransportMaintenanceRecord.empty(vehicleId),
          onSave: _saveRecord,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleRecords = _vehicleFilter == 'Todas'
        ? _records
        : _records.where((record) => record.vehicleId == _vehicleFilter);
    final readyUnits = widget.vehicles
        .where((vehicle) =>
            vehicle.status != 'Mantto' && vehicle.status != 'Fuera')
        .length;
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Mantenimiento',
            subtitle: 'Controles por flota antes de aceptar rutas y salidas.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: StatusBanner(
              icon: Icons.verified_outlined,
              title: '$readyUnits unidades listas para ruta',
              subtitle:
                  '${_records.length} controles registrados entre seguridad, documentos y preventivo.',
              color: AppColors.mint,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: FilledButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Nuevo control'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.mint,
                foregroundColor: AppColors.canvasDeep,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  MaintenanceFleetFilterChip(
                    selected: _vehicleFilter == 'Todas',
                    label: 'Toda la flota',
                    onTap: () => setState(() => _vehicleFilter = 'Todas'),
                  ),
                  ...widget.vehicles.map(
                    (vehicle) => MaintenanceFleetFilterChip(
                      selected: _vehicleFilter == vehicle.id,
                      label: vehicle.name,
                      onTap: () => setState(() => _vehicleFilter = vehicle.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...visibleRecords.map(
            (record) => TransportMaintenanceCard(
              record: record,
              vehicle: _vehicleFor(record.vehicleId),
              color: _statusColor(record.status),
              onEdit: () => _openEditor(record),
              onDelete: () => _deleteRecord(record),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class MaintenanceFleetFilterChip extends StatelessWidget {
  const MaintenanceFleetFilterChip({
    super.key,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        avatar: Icon(
          selected ? Icons.check_circle_rounded : Icons.airport_shuttle_rounded,
          size: 18,
          color: selected ? AppColors.canvasDeep : AppColors.mint,
        ),
        backgroundColor:
            selected ? AppColors.mint : Colors.white.withValues(alpha: 0.055),
        labelStyle: TextStyle(
          color: selected ? AppColors.canvasDeep : Colors.white,
          fontWeight: FontWeight.w900,
        ),
        side: BorderSide(
          color:
              selected ? AppColors.mint : Colors.white.withValues(alpha: 0.14),
        ),
      ),
    );
  }
}

class TransportMaintenanceCard extends StatelessWidget {
  const TransportMaintenanceCard({
    super.key,
    required this.record,
    required this.vehicle,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  final TransportMaintenanceRecord record;
  final TransportVehicle vehicle;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2.25,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: vehicle.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xE6000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: StatusPill(text: record.status, color: color),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.control,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${vehicle.name} · ${record.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                          icon: Icons.event_available_outlined,
                          label: record.dueDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GhostStat(
                          icon: Icons.speed_outlined,
                          label: record.kilometers,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                          icon: Icons.home_repair_service_outlined,
                          label: record.provider,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GhostStat(
                          icon: Icons.attach_money_rounded,
                          label: record.cost,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GhostStat(
                    icon: Icons.fact_check_outlined,
                    label: record.notes,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Gestionar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: 'Eliminar control',
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransportMaintenanceFormScreen extends StatefulWidget {
  const TransportMaintenanceFormScreen({
    super.key,
    required this.vehicles,
    required this.record,
    required this.onSave,
  });

  final List<TransportVehicle> vehicles;
  final TransportMaintenanceRecord record;
  final ValueChanged<TransportMaintenanceRecord> onSave;

  @override
  State<TransportMaintenanceFormScreen> createState() =>
      _TransportMaintenanceFormScreenState();
}

class _TransportMaintenanceFormScreenState
    extends State<TransportMaintenanceFormScreen> {
  late String _vehicleId = widget.record.vehicleId;
  late String _category = widget.record.category;
  late String _status = widget.record.status;
  late final TextEditingController _control =
      TextEditingController(text: widget.record.control);
  late final TextEditingController _dueDate =
      TextEditingController(text: widget.record.dueDate);
  late final TextEditingController _kilometers =
      TextEditingController(text: widget.record.kilometers);
  late final TextEditingController _provider =
      TextEditingController(text: widget.record.provider);
  late final TextEditingController _cost =
      TextEditingController(text: widget.record.cost);
  late final TextEditingController _notes =
      TextEditingController(text: widget.record.notes);

  @override
  void dispose() {
    _control.dispose();
    _dueDate.dispose();
    _kilometers.dispose();
    _provider.dispose();
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (_control.text.trim().isEmpty || _dueDate.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega control y vencimiento.')),
      );
      return;
    }
    widget.onSave(
      TransportMaintenanceRecord(
        id: widget.record.id,
        vehicleId: _vehicleId,
        control: _control.text.trim(),
        category: _category,
        dueDate: _dueDate.text.trim(),
        kilometers: _kilometers.text.trim(),
        provider: _provider.text.trim(),
        cost: _cost.text.trim(),
        status: _status,
        notes: _notes.text.trim(),
      ),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Control de mantenimiento guardado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = widget.vehicles.firstWhere(
      (vehicle) => vehicle.id == _vehicleId,
      orElse: () => widget.vehicles.isNotEmpty
          ? widget.vehicles.first
          : TransportVehicle.empty(),
    );
    return Scaffold(
      extendBody: true,
      body: AppGradientScaffold(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            AppHeader(
              title: _control.text.trim().isEmpty
                  ? 'Nuevo control'
                  : 'Gestionar control',
              subtitle: 'Registro operativo por unidad de flota.',
              trailing: IconButton.filledTonal(
                tooltip: 'Volver',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: PremiumSurface(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 2.1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: TecaigoImage(
                          src: selectedVehicle.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const SectionTitle(
                      title: 'Unidad',
                      subtitle: 'Selecciona la flota afectada por el control.',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.vehicles.map((vehicle) {
                        final selected = _vehicleId == vehicle.id;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(vehicle.name),
                          onSelected: (_) =>
                              setState(() => _vehicleId = vehicle.id),
                          selectedColor: AppColors.tealMist,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    EventTextField(
                      label: 'Control',
                      controller: _control,
                      icon: Icons.build_circle_outlined,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: EventTextField(
                            label: 'Vence / fecha',
                            controller: _dueDate,
                            icon: Icons.event_available_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: EventTextField(
                            label: 'Km / intervalo',
                            controller: _kilometers,
                            icon: Icons.speed_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: EventTextField(
                            label: 'Proveedor',
                            controller: _provider,
                            icon: Icons.home_repair_service_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: EventTextField(
                            label: 'Costo',
                            controller: _cost,
                            icon: Icons.attach_money_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    EventTextField(
                      label: 'Notas / bloqueo operativo',
                      controller: _notes,
                      icon: Icons.fact_check_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Preventivo', 'Seguridad', 'Documentacion']
                          .map((category) {
                        final selected = _category == category;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(category),
                          onSelected: (_) =>
                              setState(() => _category = category),
                          selectedColor: AppColors.tealMist,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Programado',
                        'Proximo',
                        'Listo',
                        'OK',
                        'Bloqueado'
                      ].map((status) {
                        final selected = _status == status;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(status),
                          onSelected: (_) => setState(() => _status = status),
                          selectedColor: AppColors.tealMist,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar control'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.mint,
                        foregroundColor: AppColors.canvasDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class TransportProfileScreen extends StatelessWidget {
  const TransportProfileScreen({
    super.key,
    required this.availableOperators,
    required this.acceptUrgent,
    required this.onAvailableChanged,
    required this.onUrgentChanged,
  });

  final bool availableOperators;
  final bool acceptUrgent;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<bool> onUrgentChanged;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Perfil transportista',
            subtitle: 'Reglas de visibilidad, cobertura y solicitudes.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  EventToggleRow(
                      icon: Icons.route_outlined,
                      title: 'Visible para tour operadores',
                      value: availableOperators,
                      onChanged: onAvailableChanged),
                  EventToggleRow(
                      icon: Icons.bolt_rounded,
                      title: 'Aceptar asignaciones urgentes',
                      value: acceptUrgent,
                      onChanged: onUrgentChanged),
                  const SizedBox(height: 12),
                  const BusinessActionCard(
                    icon: Icons.map_outlined,
                    title: 'El Salvador, Guatemala y Honduras',
                    subtitle: 'Cobertura regional disponible',
                    color: AppColors.mint,
                  ),
                  const SizedBox(height: 10),
                  const BusinessActionCard(
                    icon: Icons.support_agent_rounded,
                    title: 'WhatsApp +503 7000 4040',
                    subtitle: 'Contacto operativo 24/7',
                    color: AppColors.yellow,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class BusinessPlaceProfile {
  const BusinessPlaceProfile({
    required this.id,
    required this.name,
    required this.branchName,
    required this.category,
    required this.location,
    required this.hours,
    required this.description,
    required this.contact,
  });

  final String id;
  final String name;
  final String branchName;
  final String category;
  final String location;
  final String hours;
  final String description;
  final String contact;

  factory BusinessPlaceProfile.seed() {
    return const BusinessPlaceProfile(
      id: 'gastro-ataco',
      name: 'Gastro Ataco',
      branchName: 'Sede Ataco',
      category: 'Restaurante turistico',
      location: 'Concepcion de Ataco',
      hours: '8:00 AM - 8:00 PM',
      description:
          'Almuerzos tipicos, cafe de altura y espacio para grupos dentro de la ruta artesanal de Ataco.',
      contact: 'WhatsApp +503 7000 0000',
    );
  }

  factory BusinessPlaceProfile.empty() {
    return BusinessPlaceProfile(
      id: 'business-${DateTime.now().microsecondsSinceEpoch}',
      name: '',
      branchName: '',
      category: '',
      location: '',
      hours: '',
      description: '',
      contact: '',
    );
  }

  factory BusinessPlaceProfile.fromJson(Map<String, dynamic> json) {
    return BusinessPlaceProfile(
      id: (json['id'] as String?) ?? 'business-fallback',
      name: (json['name'] as String?) ?? '',
      branchName: (json['branchName'] as String?) ??
          (json['agencyName'] as String?) ??
          (json['location'] as String?) ??
          '',
      category: (json['category'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      hours: (json['hours'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      contact: (json['contact'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'branchName': branchName,
      'category': category,
      'location': location,
      'hours': hours,
      'description': description,
      'contact': contact,
    };
  }
}

class BusinessProfileCrudScreen extends StatelessWidget {
  const BusinessProfileCrudScreen({
    super.key,
    required this.businesses,
    required this.activeBusinessId,
    required this.photo,
    required this.galleryPhotos,
    required this.onSelectBusiness,
    required this.onSaveBusiness,
    required this.onDeleteBusiness,
    required this.onPhotoSelected,
    required this.onAddGalleryPhoto,
    required this.onDeleteGalleryPhoto,
    required this.onSetCoverPhoto,
  });

  final List<BusinessPlaceProfile> businesses;
  final String activeBusinessId;
  final String photo;
  final List<BusinessGalleryPhoto> galleryPhotos;
  final ValueChanged<BusinessPlaceProfile> onSelectBusiness;
  final ValueChanged<BusinessPlaceProfile> onSaveBusiness;
  final ValueChanged<BusinessPlaceProfile> onDeleteBusiness;
  final ValueChanged<String> onPhotoSelected;
  final VoidCallback onAddGalleryPhoto;
  final ValueChanged<BusinessGalleryPhoto> onDeleteGalleryPhoto;
  final ValueChanged<BusinessGalleryPhoto> onSetCoverPhoto;

  void _openEditor(BuildContext context, BusinessPlaceProfile business) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BusinessProfileFormScreen(
          business: business,
          photo: photo,
          galleryPhotos: galleryPhotos,
          onSaveBusiness: onSaveBusiness,
          onPhotoSelected: onPhotoSelected,
          onAddGalleryPhoto: onAddGalleryPhoto,
          onDeleteGalleryPhoto: onDeleteGalleryPhoto,
          onSetCoverPhoto: onSetCoverPhoto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Localidades y agencias',
            subtitle:
                'Administra cada sede, sucursal o agencia visible en TeCaiGO.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      _openEditor(context, BusinessPlaceProfile.empty()),
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: const Text('Nueva localidad'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.canvasDeep,
                  ),
                ),
                const SizedBox(height: 14),
                ...businesses.map(
                  (business) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BusinessProfileCrudCard(
                      business: business,
                      selected: business.id == activeBusinessId,
                      canDelete: businesses.length > 1,
                      onSelect: () => onSelectBusiness(business),
                      onEdit: () => _openEditor(context, business),
                      onDelete: () => onDeleteBusiness(business),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class BusinessProfileCrudCard extends StatelessWidget {
  const BusinessProfileCrudCard({
    super.key,
    required this.business,
    required this.selected,
    required this.canDelete,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final BusinessPlaceProfile business;
  final bool selected;
  final bool canDelete;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (selected ? AppColors.mint : AppColors.yellow)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppColors.mint.withValues(alpha: 0.44)
                        : AppColors.line,
                  ),
                ),
                child: Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.storefront_rounded,
                  color: selected ? AppColors.mint : AppColors.yellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name.trim().isEmpty
                          ? 'Empresa sin nombre'
                          : business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        business.branchName.trim().isEmpty
                            ? 'Localidad sin nombre'
                            : business.branchName,
                        business.location,
                      ].where((item) => item.trim().isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.mint),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: canDelete ? onDelete : null,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.coral),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSelect,
                  icon: Icon(selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded),
                  label: Text(selected ? 'Activo' : 'Usar en la app'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Gestionar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BusinessProfileFormScreen extends StatefulWidget {
  const BusinessProfileFormScreen({
    super.key,
    required this.business,
    required this.photo,
    required this.galleryPhotos,
    required this.onSaveBusiness,
    required this.onPhotoSelected,
    required this.onAddGalleryPhoto,
    required this.onDeleteGalleryPhoto,
    required this.onSetCoverPhoto,
  });

  final BusinessPlaceProfile business;
  final String photo;
  final List<BusinessGalleryPhoto> galleryPhotos;
  final ValueChanged<BusinessPlaceProfile> onSaveBusiness;
  final ValueChanged<String> onPhotoSelected;
  final VoidCallback onAddGalleryPhoto;
  final ValueChanged<BusinessGalleryPhoto> onDeleteGalleryPhoto;
  final ValueChanged<BusinessGalleryPhoto> onSetCoverPhoto;

  @override
  State<BusinessProfileFormScreen> createState() =>
      _BusinessProfileFormScreenState();
}

class _BusinessProfileFormScreenState extends State<BusinessProfileFormScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.business.name);
  late final TextEditingController _branchName =
      TextEditingController(text: widget.business.branchName);
  late final TextEditingController _category =
      TextEditingController(text: widget.business.category);
  late final TextEditingController _location =
      TextEditingController(text: widget.business.location);
  late final TextEditingController _hours =
      TextEditingController(text: widget.business.hours);
  late final TextEditingController _description =
      TextEditingController(text: widget.business.description);
  late final TextEditingController _contact =
      TextEditingController(text: widget.business.contact);
  late String _coverPhoto;
  int _photoRevision = 0;

  @override
  void initState() {
    super.initState();
    _coverPhoto = widget.photo;
  }

  @override
  void dispose() {
    _name.dispose();
    _branchName.dispose();
    _category.dispose();
    _location.dispose();
    _hours.dispose();
    _description.dispose();
    _contact.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega el nombre comercial.')),
      );
      return;
    }
    widget.onSaveBusiness(
      BusinessPlaceProfile(
        id: widget.business.id,
        name: _name.text.trim(),
        branchName: _branchName.text.trim(),
        category: _category.text.trim(),
        location: _location.text.trim(),
        hours: _hours.text.trim(),
        description: _description.text.trim(),
        contact: _contact.text.trim(),
      ),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comercio guardado.')),
    );
  }

  void _addGalleryPhoto() {
    widget.onAddGalleryPhoto();
    setState(() => _photoRevision += 1);
  }

  void _deleteGalleryPhoto(BusinessGalleryPhoto photo) {
    widget.onDeleteGalleryPhoto(photo);
    if (_coverPhoto == photo.src && widget.galleryPhotos.isNotEmpty) {
      _coverPhoto = widget.galleryPhotos.first.src;
    }
    setState(() => _photoRevision += 1);
  }

  void _setCoverPhoto(BusinessGalleryPhoto photo) {
    widget.onSetCoverPhoto(photo);
    setState(() => _coverPhoto = photo.src);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AppGradientScaffold(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            AppHeader(
              title: widget.business.name.trim().isEmpty
                  ? 'Nueva localidad'
                  : 'Gestionar localidad',
              subtitle: 'Administra una sede, sucursal o agencia del comercio.',
              trailing: IconButton.filledTonal(
                tooltip: 'Volver',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: PremiumSurface(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EventTextField(
                        label: 'Comercio o marca',
                        controller: _name,
                        icon: Icons.storefront_rounded),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Localidad o agencia',
                        controller: _branchName,
                        icon: Icons.account_tree_outlined),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Categoria',
                        controller: _category,
                        icon: Icons.category_outlined),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Ubicacion',
                        controller: _location,
                        icon: Icons.place_outlined),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Horario',
                        controller: _hours,
                        icon: Icons.schedule_rounded),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Descripcion',
                        controller: _description,
                        icon: Icons.notes_rounded,
                        maxLines: 3),
                    const SizedBox(height: 12),
                    EventTextField(
                        label: 'Contacto',
                        controller: _contact,
                        icon: Icons.call_outlined),
                    const SizedBox(height: 16),
                    BusinessPlaceGallery(
                      key: ValueKey('gallery-$_photoRevision-$_coverPhoto'),
                      coverPhoto: _coverPhoto,
                      photos: widget.galleryPhotos,
                      onAddPhoto: _addGalleryPhoto,
                      onDeletePhoto: _deleteGalleryPhoto,
                      onSetCoverPhoto: _setCoverPhoto,
                    ),
                    const SizedBox(height: 18),
                    BusinessMapSection(location: _location),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Volver'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save_rounded),
                            label: const Text('Guardar'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: AppColors.mint,
                              foregroundColor: AppColors.canvasDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class BusinessGalleryPhoto {
  const BusinessGalleryPhoto({
    required this.id,
    required this.src,
    required this.label,
  });

  final String id;
  final String src;
  final String label;
}

class BusinessPlaceGallery extends StatelessWidget {
  const BusinessPlaceGallery({
    super.key,
    required this.coverPhoto,
    required this.photos,
    required this.onAddPhoto,
    required this.onDeletePhoto,
    required this.onSetCoverPhoto,
  });

  final String coverPhoto;
  final List<BusinessGalleryPhoto> photos;
  final VoidCallback onAddPhoto;
  final ValueChanged<BusinessGalleryPhoto> onDeletePhoto;
  final ValueChanged<BusinessGalleryPhoto> onSetCoverPhoto;

  @override
  Widget build(BuildContext context) {
    final cover = photos.firstWhere(
      (photo) => photo.src == coverPhoto,
      orElse: () => photos.isEmpty
          ? const BusinessGalleryPhoto(id: 'empty', src: '', label: 'Portada')
          : photos.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: SectionTitle(
                title: 'Fotos del establecimiento',
                subtitle:
                    'Administra portada y galeria visible para turistas y operadores',
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Agregar foto',
              onPressed: onAddPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1.7,
            child: cover.src.isEmpty
                ? const _PhotoPlaceholder()
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      TecaigoImage(src: cover.src, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x11000000), Color(0xBB000000)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 14,
                        child:
                            StatusPill(text: 'Portada', color: AppColors.mint),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: FilledButton.icon(
                          onPressed: onAddPhoto,
                          icon: const Icon(Icons.add_photo_alternate_outlined,
                              size: 18),
                          label: const Text('Agregar'),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                AppColors.canvas.withValues(alpha: 0.78),
                            foregroundColor: AppColors.mint,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...photos.map((photo) {
              final isCover = photo.src == coverPhoto;
              return SizedBox(
                width: 142,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.18,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        TecaigoImage(src: photo.src, fit: BoxFit.cover),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x22000000), Color(0xCC000000)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: StatusPill(
                            text: isCover ? 'Portada' : photo.label,
                            color: isCover ? AppColors.mint : AppColors.yellow,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Row(
                            children: [
                              _PhotoActionButton(
                                tooltip: 'Usar como portada',
                                icon: isCover
                                    ? Icons.check_circle_rounded
                                    : Icons.wallpaper_rounded,
                                onTap: () => onSetCoverPhoto(photo),
                              ),
                              const SizedBox(width: 6),
                              _PhotoActionButton(
                                tooltip: 'Eliminar foto',
                                icon: Icons.delete_outline_rounded,
                                onTap: photos.length <= 1
                                    ? null
                                    : () => onDeletePhoto(photo),
                                destructive: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            InkWell(
              onTap: onAddPhoto,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 142,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.mint.withValues(alpha: 0.32)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.mint, size: 32),
                    SizedBox(height: 8),
                    Text('Agregar foto',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhotoActionButton extends StatelessWidget {
  const _PhotoActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: onTap == null ? 0.28 : 0.58),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap == null
                ? Colors.white.withValues(alpha: 0.32)
                : destructive
                    ? AppColors.coral
                    : AppColors.mint,
          ),
        ),
      ),
    );
  }
}

class BusinessPhotoCrudSheet extends StatelessWidget {
  const BusinessPhotoCrudSheet({
    super.key,
    required this.coverPhoto,
    required this.photos,
    required this.onAddPhoto,
    required this.onDeletePhoto,
    required this.onSetCoverPhoto,
  });

  final String coverPhoto;
  final List<BusinessGalleryPhoto> photos;
  final VoidCallback onAddPhoto;
  final ValueChanged<BusinessGalleryPhoto> onDeletePhoto;
  final ValueChanged<BusinessGalleryPhoto> onSetCoverPhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        const SectionTitle(
          title: 'Gestionar fotos',
          subtitle: 'Agrega, elimina o define la portada del comercio',
        ),
        const SizedBox(height: 14),
        ...photos.map(
          (photo) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: photo.src == coverPhoto
                      ? AppColors.mint.withValues(alpha: 0.5)
                      : AppColors.line,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: TecaigoImage(
                        src: photo.src,
                        width: 66,
                        height: 58,
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(photo.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 5),
                        Text(
                          photo.src == coverPhoto
                              ? 'Portada principal'
                              : 'Foto de galeria',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.58),
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Usar como portada',
                    onPressed: () {
                      onSetCoverPhoto(photo);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      photo.src == coverPhoto
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: photo.src == coverPhoto
                          ? AppColors.mint
                          : Colors.white.withValues(alpha: 0.64),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Eliminar foto',
                    onPressed: photos.length <= 1
                        ? null
                        : () {
                            onDeletePhoto(photo);
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.coral),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        FilledButton.icon(
          onPressed: () {
            onAddPhoto();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto agregada a la galeria.')),
            );
          },
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Agregar foto'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class BusinessMapSection extends StatelessWidget {
  const BusinessMapSection({
    super.key,
    required this.location,
  });

  final TextEditingController location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Mapa y ubicacion',
          subtitle:
              'Punto rastreable para turistas, tour operadores y transporte',
        ),
        const SizedBox(height: 12),
        Container(
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const TecaigoImage(
                  src: 'assets/turismo/ataco_map.png', fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x11000000), Color(0x66000000)],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.mint, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        location.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const StatusPill(text: 'Visible', color: AppColors.lime),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TouristBusinessMenuScreen extends StatefulWidget {
  const TouristBusinessMenuScreen({
    super.key,
    required this.menuHighlight,
    required this.onChanged,
  });

  final TextEditingController menuHighlight;
  final VoidCallback onChanged;

  @override
  State<TouristBusinessMenuScreen> createState() =>
      _TouristBusinessMenuScreenState();
}

class _TouristBusinessMenuScreenState extends State<TouristBusinessMenuScreen> {
  late final List<BusinessMenuDish> _dishes = [
    const BusinessMenuDish(
      id: 'parrillada-mariscos',
      name: 'Parrillada de mariscos',
      detail: 'Pescado, pulpo, calamares y camarones a la parrilla.',
      price: '\$18.50',
      image: 'assets/comercio/parrillada_mariscos.jpeg',
      icon: Icons.set_meal_rounded,
    ),
    const BusinessMenuDish(
      id: 'sarten-pescaresc',
      name: 'Sarten Pescaresc',
      detail: 'Mariscos en salsa roja, limon fresco y toque picante.',
      price: '\$16.00',
      image: 'assets/comercio/pescaresc_sarten.jpeg',
      icon: Icons.local_fire_department_rounded,
    ),
    const BusinessMenuDish(
      id: 'salmon-mediterraneo',
      name: 'Salmon mediterraneo',
      detail: 'Salmon sellado con tomates, aceitunas y hierbas.',
      price: '\$14.75',
      image: 'assets/comercio/salmon_mediterraneo.jpeg',
      icon: Icons.restaurant,
    ),
    const BusinessMenuDish(
      id: 'salmon-granada',
      name: 'Salmon con granada',
      detail: 'Filete con vegetales, reduccion dulce y perejil fresco.',
      price: '\$15.50',
      image: 'assets/comercio/salmon_granada.jpeg',
      icon: Icons.dinner_dining_rounded,
    ),
  ];

  void _addDish() {
    setState(() {
      _dishes.add(BusinessMenuDish(
        id: 'dish-${DateTime.now().microsecondsSinceEpoch}',
        name: 'Nuevo plato turistico',
        detail: 'Agrega descripcion, foto y precio para publicar en el menu.',
        price: '\$0.00',
        image: 'assets/comercio/parrillada_mariscos.jpeg',
        icon: Icons.restaurant_menu_rounded,
      ));
    });
    widget.onChanged();
  }

  void _updateDish(BusinessMenuDish dish) {
    setState(() {
      final index = _dishes.indexWhere((item) => item.id == dish.id);
      if (index != -1) _dishes[index] = dish;
    });
    widget.onChanged();
  }

  void _deleteDish(BusinessMenuDish dish) {
    setState(() => _dishes.removeWhere((item) => item.id == dish.id));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Menu y servicios',
            subtitle: 'Oferta que turistas y operadores pueden vender.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  EventTextField(
                      label: 'Resumen de menu',
                      controller: widget.menuHighlight,
                      icon: Icons.restaurant_menu_rounded,
                      maxLines: 2,
                      onChanged: (_) => widget.onChanged()),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _addDish,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Agregar plato'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.mint,
                      foregroundColor: AppColors.canvasDeep,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._dishes.map(
                    (dish) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MenuOfferTile(
                        dish: dish,
                        onEdit: () => showAppSheet(
                          context,
                          BusinessDishCrudSheet(
                            dish: dish,
                            onSave: _updateDish,
                            onDelete: _deleteDish,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class BusinessMenuDish {
  const BusinessMenuDish({
    required this.id,
    required this.name,
    required this.detail,
    required this.price,
    required this.image,
    required this.icon,
  });

  final String id;
  final String name;
  final String detail;
  final String price;
  final String image;
  final IconData icon;

  BusinessMenuDish copyWith({
    String? name,
    String? detail,
    String? price,
    String? image,
    IconData? icon,
  }) {
    return BusinessMenuDish(
      id: id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      price: price ?? this.price,
      image: image ?? this.image,
      icon: icon ?? this.icon,
    );
  }
}

class MenuOfferTile extends StatelessWidget {
  const MenuOfferTile({
    super.key,
    required this.dish,
    required this.onEdit,
  });

  final BusinessMenuDish dish;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: dish.image.isEmpty
                  ? Container(
                      width: 86,
                      height: 76,
                      color: Colors.white.withValues(alpha: 0.055),
                      child: const Icon(Icons.add_photo_alternate_outlined,
                          color: AppColors.mint),
                    )
                  : TecaigoImage(
                      src: dish.image,
                      width: 86,
                      height: 76,
                      fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(dish.icon, color: AppColors.mint, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(dish.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(dish.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          height: 1.2,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(dish.price,
                          style: const TextStyle(
                              color: AppColors.yellow,
                              fontWeight: FontWeight.w900)),
                      const Spacer(),
                      const Icon(Icons.edit_outlined,
                          color: AppColors.mint, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessDishCrudSheet extends StatefulWidget {
  const BusinessDishCrudSheet({
    super.key,
    required this.dish,
    required this.onSave,
    required this.onDelete,
  });

  final BusinessMenuDish dish;
  final ValueChanged<BusinessMenuDish> onSave;
  final ValueChanged<BusinessMenuDish> onDelete;

  @override
  State<BusinessDishCrudSheet> createState() => _BusinessDishCrudSheetState();
}

class _BusinessDishCrudSheetState extends State<BusinessDishCrudSheet> {
  late final TextEditingController name =
      TextEditingController(text: widget.dish.name);
  late final TextEditingController detail =
      TextEditingController(text: widget.dish.detail);
  late final TextEditingController price =
      TextEditingController(text: widget.dish.price);
  late String _selectedImage = widget.dish.image;
  int _photoSeed = 0;

  static const _sampleUploads = [
    'assets/comercio/parrillada_mariscos.jpeg',
    'assets/comercio/pescaresc_sarten.jpeg',
    'assets/comercio/salmon_mediterraneo.jpeg',
    'assets/comercio/salmon_granada.jpeg',
  ];

  @override
  void dispose() {
    name.dispose();
    detail.dispose();
    price.dispose();
    super.dispose();
  }

  void _addOrReplacePhoto() {
    setState(() {
      _selectedImage = _sampleUploads[_photoSeed % _sampleUploads.length];
      _photoSeed += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        const SectionTitle(
          title: 'Detalle del plato',
          subtitle:
              'Foto, descripcion y precio visible para turistas y operadores',
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1.9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_selectedImage.isEmpty)
                  Container(
                    color: Colors.white.withValues(alpha: 0.055),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.mint, size: 42),
                        SizedBox(height: 8),
                        Text('Sin imagen del plato',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                  )
                else
                  TecaigoImage(src: _selectedImage, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x11000000), Color(0xAA000000)],
                    ),
                  ),
                ),
                const Positioned(
                  left: 14,
                  bottom: 12,
                  child: StatusPill(
                      text: 'Imagen del plato', color: AppColors.mint),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined,
                      color: AppColors.mint, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('CRUD de imagen del plato',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  StatusPill(
                    text: _selectedImage.isEmpty ? 'Sin foto' : '1 foto',
                    color: _selectedImage.isEmpty
                        ? AppColors.coral
                        : AppColors.mint,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _addOrReplacePhoto,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label:
                          Text(_selectedImage.isEmpty ? 'Agregar' : 'Cambiar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: AppColors.canvasDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedImage.isEmpty
                          ? null
                          : () => setState(() => _selectedImage = ''),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.coral,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_selectedImage.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.mint.withValues(alpha: 0.28)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: TecaigoImage(
                      src: _selectedImage,
                      width: 58,
                      height: 48,
                      fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Foto agregada al plato',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
                const Icon(Icons.check_circle_rounded, color: AppColors.mint),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        EventTextField(
            label: 'Nombre del plato',
            controller: name,
            icon: Icons.restaurant_menu_rounded),
        const SizedBox(height: 10),
        EventTextField(
            label: 'Detalle',
            controller: detail,
            icon: Icons.notes_rounded,
            maxLines: 2),
        const SizedBox(height: 10),
        EventTextField(
            label: 'Precio',
            controller: price,
            icon: Icons.attach_money_rounded),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  widget.onDelete(widget.dish);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.coral,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  widget.onSave(widget.dish.copyWith(
                    name: name.text,
                    detail: detail.text,
                    price: price.text,
                    image: _selectedImage,
                  ));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: AppColors.canvasDeep,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TouristBusinessCapacityScreen extends StatelessWidget {
  const TouristBusinessCapacityScreen({
    super.key,
    required this.capacity,
    required this.tables,
    required this.rooms,
    required this.acceptReservations,
    required this.instantConfirm,
    required this.onCapacityChanged,
    required this.onTablesChanged,
    required this.onRoomsChanged,
    required this.onAcceptReservations,
    required this.onInstantConfirm,
  });

  final int capacity;
  final int tables;
  final int rooms;
  final bool acceptReservations;
  final bool instantConfirm;
  final ValueChanged<double> onCapacityChanged;
  final ValueChanged<double> onTablesChanged;
  final ValueChanged<double> onRoomsChanged;
  final ValueChanged<bool> onAcceptReservations;
  final ValueChanged<bool> onInstantConfirm;

  @override
  Widget build(BuildContext context) {
    final seated = (capacity * 0.72).round();
    final standing = capacity - seated;
    final groupBlocks = (tables / 3).ceil();
    final reservationMode = instantConfirm ? 'Inmediata' : 'Manual';
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Capacidad instalada',
            subtitle: 'Cupos reales para grupos, reservas y operadores.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: MiniKpi(label: 'Total', value: '$capacity')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: MiniKpi(label: 'Mesas', value: '$tables')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: MiniKpi(label: 'Privados', value: '$rooms')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderField(
                      label: 'Capacidad total',
                      value: capacity.toDouble(),
                      min: 10,
                      max: 220,
                      suffix: '$capacity personas',
                      onChanged: onCapacityChanged),
                  SliderField(
                      label: 'Mesas / espacios',
                      value: tables.toDouble(),
                      min: 1,
                      max: 60,
                      suffix: '$tables',
                      onChanged: onTablesChanged),
                  SliderField(
                      label: 'Habitaciones / areas privadas',
                      value: rooms.toDouble(),
                      min: 0,
                      max: 40,
                      suffix: '$rooms',
                      onChanged: onRoomsChanged),
                  const SizedBox(height: 10),
                  EventToggleRow(
                      icon: Icons.bookmark_added_outlined,
                      title: 'Aceptar reservas',
                      value: acceptReservations,
                      onChanged: onAcceptReservations),
                  EventToggleRow(
                      icon: Icons.flash_on_rounded,
                      title: 'Confirmacion inmediata',
                      value: instantConfirm,
                      onChanged: onInstantConfirm),
                  const SizedBox(height: 14),
                  const SectionTitle(
                    title: 'Distribucion visible',
                    subtitle: 'Como se muestra tu capacidad al vender espacios',
                  ),
                  const SizedBox(height: 10),
                  CapacityBreakdownRow(
                    icon: Icons.chair_outlined,
                    label: 'Sentados',
                    value: seated,
                    total: capacity,
                    color: AppColors.mint,
                  ),
                  const SizedBox(height: 10),
                  CapacityBreakdownRow(
                    icon: Icons.groups_2_outlined,
                    label: 'Eventos mixtos',
                    value: standing,
                    total: capacity,
                    color: AppColors.yellow,
                  ),
                  const SizedBox(height: 10),
                  CapacityBreakdownRow(
                    icon: Icons.meeting_room_outlined,
                    label: 'Areas privadas',
                    value: rooms,
                    total: rooms < 1 ? 1 : rooms + tables,
                    color: const Color(0xFF65C7F7),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: CapacityRuleCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'Bloques',
                    value: '$groupBlocks',
                    subtitle: 'turnos sugeridos',
                    color: AppColors.mint,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CapacityRuleCard(
                    icon: Icons.verified_outlined,
                    title: 'Reserva',
                    value: acceptReservations ? reservationMode : 'Cerrada',
                    subtitle: acceptReservations
                        ? 'visible al cliente'
                        : 'sin solicitudes',
                    color:
                        acceptReservations ? AppColors.lime : AppColors.coral,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: StatusBanner(
              icon: Icons.groups_2_outlined,
              title: '$capacity personas disponibles',
              subtitle:
                  'Operadores, turistas y transportistas veran este limite antes de reservar o solicitar espacio.',
              color: AppColors.lime,
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class CapacityBreakdownRow extends StatelessWidget {
  const CapacityBreakdownRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = total <= 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
              Text('$value',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class CapacityRuleCard extends StatelessWidget {
  const CapacityRuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.56),
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class TouristBusinessPublishScreen extends StatelessWidget {
  const TouristBusinessPublishScreen({
    super.key,
    required this.publishedClient,
    required this.publishedOperators,
    required this.acceptReservations,
    required this.onClientChanged,
    required this.onOperatorsChanged,
  });

  final bool publishedClient;
  final bool publishedOperators;
  final bool acceptReservations;
  final ValueChanged<bool> onClientChanged;
  final ValueChanged<bool> onOperatorsChanged;

  @override
  Widget build(BuildContext context) {
    final activeChannels = [
      if (publishedClient) 'Turistas',
      if (publishedOperators) 'Operadores',
      if (acceptReservations) 'Reservas',
    ];
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Publicacion',
            subtitle: 'Controla donde aparece tu comercio turistico.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PublishStatusPreview(
              activeChannels: activeChannels,
              acceptReservations: acceptReservations,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Canales de salida',
                    subtitle:
                        'Define quien puede encontrar e interactuar con tu comercio',
                  ),
                  const SizedBox(height: 12),
                  ShareTargetTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Vista turista',
                    subtitle: 'Aparece en busqueda, aliados y compra directa.',
                    value: publishedClient,
                    onChanged: onClientChanged,
                  ),
                  ShareTargetTile(
                    icon: Icons.route_outlined,
                    title: 'Tour operadores',
                    subtitle: 'Disponible para rutas, cupos y solicitudes.',
                    value: publishedOperators,
                    onChanged: onOperatorsChanged,
                  ),
                  ShareTargetTile(
                    icon: Icons.event_available_outlined,
                    title: 'Reservas activas',
                    subtitle: acceptReservations
                        ? 'Tu comercio acepta solicitudes de reserva.'
                        : 'Activa reservas en Capacidad.',
                    value: acceptReservations,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SectionTitle(
                    title: 'Tipo de publicacion',
                    subtitle: 'Acciones que alimentan el homefeed comercial',
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      PublishTypeChip(
                          icon: Icons.storefront_outlined,
                          label: 'Perfil',
                          color: AppColors.mint),
                      PublishTypeChip(
                          icon: Icons.restaurant_menu_outlined,
                          label: 'Menu',
                          color: AppColors.yellow),
                      PublishTypeChip(
                          icon: Icons.local_offer_outlined,
                          label: 'Promo',
                          color: AppColors.lime),
                      PublishTypeChip(
                          icon: Icons.event_seat_outlined,
                          label: 'Cupos',
                          color: Color(0xFF65C7F7)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: const [
                  PublishChecklistTile(
                    icon: Icons.photo_library_outlined,
                    title: 'Galeria lista',
                    subtitle:
                        'Fotos visibles en busqueda y detalle del comercio',
                    color: AppColors.mint,
                  ),
                  PublishChecklistTile(
                    icon: Icons.map_outlined,
                    title: 'Ubicacion rastreable',
                    subtitle:
                        'Turistas, operadores y transporte pueden ubicarte',
                    color: AppColors.yellow,
                  ),
                  PublishChecklistTile(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Menu comercial',
                    subtitle: 'Platos con foto, precio y detalle operativo',
                    color: AppColors.lime,
                  ),
                  PublishChecklistTile(
                    icon: Icons.groups_2_outlined,
                    title: 'Capacidad publicada',
                    subtitle: 'Limites claros para reservas y grupos',
                    color: Color(0xFF65C7F7),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil comercial actualizado.')),
              ),
              icon: const Icon(Icons.cloud_done_outlined),
              label: const Text('Guardar publicacion'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.mint,
                foregroundColor: AppColors.canvasDeep,
              ),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class PublishStatusPreview extends StatelessWidget {
  const PublishStatusPreview({
    super.key,
    required this.activeChannels,
    required this.acceptReservations,
  });

  final List<String> activeChannels;
  final bool acceptReservations;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: SizedBox(
              height: 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const TecaigoImage(
                      src: 'assets/turismo/ataco.jpeg', fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xDD000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: StatusPill(
                      text: activeChannels.isEmpty ? 'Borrador' : 'Publicado',
                      color: activeChannels.isEmpty
                          ? AppColors.yellow
                          : AppColors.mint,
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      'Gastro Ataco',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: GhostStat(
                    icon: Icons.visibility_outlined,
                    label: activeChannels.isEmpty
                        ? 'Sin canales'
                        : activeChannels.join(', '),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GhostStat(
                    icon: Icons.event_available_outlined,
                    label:
                        acceptReservations ? 'Reserva activa' : 'Sin reserva',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PublishTypeChip extends StatelessWidget {
  const PublishTypeChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 7),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class PublishChecklistTile extends StatelessWidget {
  const PublishChecklistTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, small: true),
          const SizedBox(width: 12),
          Expanded(child: SectionTitle(title: title, subtitle: subtitle)),
          const Icon(Icons.check_circle_rounded, color: AppColors.mint),
        ],
      ),
    );
  }
}

class ClientEventDetailSheet extends StatelessWidget {
  const ClientEventDetailSheet(
      {super.key,
      required this.event,
      required this.onReserve,
      required this.onBuy});

  final ClientEvent event;
  final VoidCallback onReserve;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return _ClientSheetFrame(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          PremiumSurface(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 230,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: event.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x11000000), Color(0xDD000000)],
                      ),
                    ),
                  ),
                  Positioned(
                      left: 16,
                      top: 16,
                      child: StatusPill(text: event.badge, color: event.color)),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(event.title,
                        style: const TextStyle(
                            fontSize: 28,
                            height: 1.02,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(event.subtitle,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76), height: 1.38)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: GhostStat(
                      icon: Icons.place_outlined, label: event.location)),
              const SizedBox(width: 10),
              Expanded(
                  child: GhostStat(
                      icon: Icons.schedule_rounded, label: event.date)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: GhostStat(
                      icon: Icons.payments_outlined, label: event.price)),
              const SizedBox(width: 10),
              Expanded(
                  child: GhostStat(
                      icon: Icons.verified_outlined,
                      label: 'Confirmacion rapida')),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Salidas disponibles',
            subtitle: 'Elige una fecha al reservar o comprar.',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: event.dateOptions
                .map((date) => AvailabilityChip(date: date, color: event.color))
                .toList(),
          ),
          const SizedBox(height: 16),
          const SectionTitle(
              title: 'Incluye',
              subtitle:
                  'Transporte, anfitrion local, cupo confirmado y soporte TeCaiGO.'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReserve,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Reservar'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onBuy,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Comprar'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.canvasDeep,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BusinessDetailSheet extends StatelessWidget {
  const BusinessDetailSheet({
    super.key,
    required this.business,
    required this.onReserve,
    required this.onBuy,
  });

  final TouristBusiness business;
  final VoidCallback onReserve;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return _ClientSheetFrame(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          PremiumSurface(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: business.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x05000000), Color(0xE8000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: StatusPill(
                        text: business.category, color: business.color),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(business.name,
                            style: const TextStyle(
                                fontSize: 28,
                                height: 1.02,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: business.color, size: 19),
                            const SizedBox(width: 5),
                            Text(business.rating,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(business.subtitle,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76), height: 1.38)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: GhostStat(
                      icon: _businessIcon(business.category),
                      label: business.category)),
              const SizedBox(width: 10),
              Expanded(
                  child: GhostStat(
                      icon: Icons.verified_outlined,
                      label: 'Aliado verificado')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: GhostStat(
                      icon: Icons.confirmation_number_outlined,
                      label: _businessPrimaryOffer(business.category))),
              const SizedBox(width: 10),
              Expanded(
                  child: GhostStat(
                      icon: Icons.support_agent_rounded,
                      label: 'Atencion directa')),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Opciones',
            subtitle:
                'Aparta cupos si estas decidiendo o compra cuando ya quieres confirmar.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReserve,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Reservar'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onBuy,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Comprar'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.canvasDeep,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _businessIcon(String category) {
  return switch (category) {
    'Boleteria' => Icons.local_activity_rounded,
    'Agencia' => Icons.flight_takeoff_rounded,
    'Restaurante' => Icons.restaurant_rounded,
    'Hostal' => Icons.hotel_rounded,
    'Transporte' => Icons.airport_shuttle_rounded,
    _ => Icons.tour_rounded,
  };
}

String _businessPrimaryOffer(String category) {
  return switch (category) {
    'Boleteria' => 'Entrada digital',
    'Agencia' => 'Paquete turistico',
    'Restaurante' => 'Mesa / consumo',
    'Hostal' => 'Habitacion',
    'Transporte' => 'Traslado',
    _ => 'Experiencia',
  };
}

class ClientReservationEditorSheet extends StatefulWidget {
  const ClientReservationEditorSheet({
    super.key,
    required this.event,
    required this.onSave,
    this.reservation,
    this.purchaseMode = false,
  });

  final ClientEvent event;
  final ClientReservation? reservation;
  final ValueChanged<ClientReservation> onSave;
  final bool purchaseMode;

  @override
  State<ClientReservationEditorSheet> createState() =>
      _ClientReservationEditorSheetState();
}

class _ClientReservationEditorSheetState
    extends State<ClientReservationEditorSheet> {
  late int _guests;
  late String _selectedDate;
  late final TextEditingController _contact;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _guests = widget.reservation?.guests ?? 1;
    _selectedDate =
        widget.reservation?.selectedDate ?? widget.event.dateOptions.first;
    _contact =
        TextEditingController(text: widget.reservation?.contact ?? 'Luis');
    _note = TextEditingController(text: widget.reservation?.note ?? '');
  }

  @override
  void dispose() {
    _contact.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final reservation = ClientReservation(
      id: widget.reservation?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      event: widget.event,
      guests: _guests,
      selectedDate: _selectedDate,
      contact: _contact.text.trim().isEmpty
          ? 'Turista TeCaiGO'
          : _contact.text.trim(),
      note: _note.text.trim(),
      status: widget.purchaseMode
          ? 'Compra'
          : widget.reservation == null
              ? 'Apartada'
              : 'Actualizada',
    );
    widget.onSave(reservation);
  }

  @override
  Widget build(BuildContext context) {
    final unit =
        int.tryParse(widget.event.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final total = unit * _guests;
    return _ClientSheetFrame(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TecaigoImage(
                    src: widget.event.imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SectionTitle(
                  title: widget.purchaseMode
                      ? 'Comprar evento'
                      : widget.reservation == null
                          ? 'Crear reserva'
                          : 'Editar reserva',
                  subtitle: widget.event.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PremiumSurface(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const IconBadge(
                    icon: Icons.group_outlined,
                    color: AppColors.mint,
                    small: true),
                const SizedBox(width: 12),
                const Expanded(
                    child: Text('Personas',
                        style: TextStyle(fontWeight: FontWeight.w900))),
                IconButton(
                  onPressed:
                      _guests > 1 ? () => setState(() => _guests -= 1) : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                Text('$_guests',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
                IconButton(
                  onPressed:
                      _guests < 12 ? () => setState(() => _guests += 1) : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SectionTitle(
            title: 'Fecha de salida',
            subtitle: 'Disponibilidad publicada por el tour operador',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.event.dateOptions
                .map(
                  (date) => ChoiceChip(
                    selected: _selectedDate == date,
                    label: Text(date),
                    onSelected: (_) => setState(() => _selectedDate = date),
                    selectedColor: AppColors.mint,
                    backgroundColor: Colors.white.withValues(alpha: 0.045),
                    labelStyle: TextStyle(
                      color: _selectedDate == date
                          ? AppColors.canvasDeep
                          : Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          EventTextField(
              label: 'Nombre de contacto',
              controller: _contact,
              icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          EventTextField(
              label: 'Notas para el operador',
              controller: _note,
              icon: Icons.notes_rounded,
              maxLines: 3),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: GhostStat(
                      icon: Icons.payments_outlined, label: '\$$total total')),
              const SizedBox(width: 10),
              Expanded(
                  child: GhostStat(
                      icon: Icons.calendar_month_outlined,
                      label: _selectedDate)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(widget.purchaseMode
                ? 'Continuar compra'
                : widget.reservation == null
                    ? 'Confirmar reserva'
                    : 'Guardar cambios'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.canvasDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class BusinessCheckoutSheet extends StatefulWidget {
  const BusinessCheckoutSheet({
    super.key,
    required this.business,
    required this.mode,
    required this.onDone,
  });

  final TouristBusiness business;
  final String mode;
  final VoidCallback onDone;

  @override
  State<BusinessCheckoutSheet> createState() => _BusinessCheckoutSheetState();
}

class _BusinessCheckoutSheetState extends State<BusinessCheckoutSheet> {
  int _quantity = 1;
  late final TextEditingController _contact;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _contact = TextEditingController(text: 'Luis');
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _contact.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = _businessUnitPrice(widget.business.category);
    final total = base * _quantity;
    return _ClientSheetFrame(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TecaigoImage(
                    src: widget.business.imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SectionTitle(
                  title: widget.mode == 'Compra' ? 'Comprar' : 'Reservar',
                  subtitle: widget.business.name,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PremiumSurface(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                IconBadge(
                    icon: _businessIcon(widget.business.category),
                    color: widget.business.color,
                    small: true),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        _businessQuantityLabel(widget.business.category),
                        style: const TextStyle(fontWeight: FontWeight.w900))),
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity -= 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                Text('$_quantity',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
                IconButton(
                  onPressed: _quantity < 12
                      ? () => setState(() => _quantity += 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          EventTextField(
              label: 'Nombre de contacto',
              controller: _contact,
              icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          EventTextField(
              label: 'Notas para el aliado',
              controller: _note,
              icon: Icons.notes_rounded,
              maxLines: 3),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: GhostStat(
                      icon: Icons.payments_outlined,
                      label: widget.mode == 'Compra'
                          ? '\$$total total'
                          : 'Sin cargo hoy')),
              const SizedBox(width: 10),
              Expanded(
                  child: GhostStat(
                      icon: widget.mode == 'Compra'
                          ? Icons.lock_outline_rounded
                          : Icons.schedule_rounded,
                      label: widget.mode == 'Compra'
                          ? 'Pago seguro'
                          : 'Apartado')),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: widget.onDone,
            icon: Icon(widget.mode == 'Compra'
                ? Icons.shopping_bag_outlined
                : Icons.bookmark_added_outlined),
            label: Text(widget.mode == 'Compra'
                ? 'Continuar compra'
                : 'Confirmar reserva'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.canvasDeep,
            ),
          ),
        ],
      ),
    );
  }
}

int _businessUnitPrice(String category) {
  return switch (category) {
    'Boleteria' => 18,
    'Agencia' => 129,
    'Restaurante' => 25,
    'Hostal' => 55,
    'Transporte' => 12,
    _ => 35,
  };
}

String _businessQuantityLabel(String category) {
  return switch (category) {
    'Boleteria' => 'Entradas',
    'Agencia' => 'Viajeros',
    'Restaurante' => 'Personas',
    'Hostal' => 'Noches',
    'Transporte' => 'Pasajeros',
    _ => 'Cupos',
  };
}

class _ClientSheetFrame extends StatelessWidget {
  const _ClientSheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: child,
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class TeCaiGoShell extends StatefulWidget {
  const TeCaiGoShell({super.key});

  @override
  State<TeCaiGoShell> createState() => _TeCaiGoShellState();
}

class _TeCaiGoShellState extends State<TeCaiGoShell> {
  int _tab = 0;
  int _notificationCount = 3;
  int _pendingRequests = 2;
  int _soldToday = 0;
  int _validationsDone = 0;
  int _newEventToken = 0;
  final List<String> _activity = [];

  @override
  void initState() {
    super.initState();
    _restoreState();
  }

  void _restoreState() {
    _notificationCount =
        int.tryParse(storageRead('tecaigo.notificationCount') ?? '') ??
            _notificationCount;
    _pendingRequests =
        int.tryParse(storageRead('tecaigo.pendingRequests') ?? '') ??
            _pendingRequests;
    _soldToday =
        int.tryParse(storageRead('tecaigo.soldToday') ?? '') ?? _soldToday;
    _validationsDone =
        int.tryParse(storageRead('tecaigo.validationsDone') ?? '') ??
            _validationsDone;
    final restoredActivity = <String>[];
    for (final item in (storageRead('tecaigo.activity') ?? '')
        .split('||')
        .where((item) => item.isNotEmpty)) {
      if (!restoredActivity.contains(item)) restoredActivity.add(item);
    }
    _activity
      ..clear()
      ..addAll(restoredActivity);
  }

  void _persistState() {
    storageWrite('tecaigo.notificationCount', '$_notificationCount');
    storageWrite('tecaigo.pendingRequests', '$_pendingRequests');
    storageWrite('tecaigo.soldToday', '$_soldToday');
    storageWrite('tecaigo.validationsDone', '$_validationsDone');
    storageWrite('tecaigo.activity', _activity.take(5).join('||'));
  }

  void _pushActivity(String text) {
    _activity.removeWhere((item) => item == text);
    _activity.insert(0, text);
    if (_activity.length > 5) {
      _activity.removeRange(5, _activity.length);
    }
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.panelSoft,
      ),
    );
  }

  void _goToCreate() {
    HapticFeedback.selectionClick();
    setState(() => _tab = 1);
  }

  void _goToNewEvent() {
    HapticFeedback.selectionClick();
    setState(() {
      _newEventToken += 1;
      _tab = 1;
    });
  }

  void _markNotificationsRead() {
    setState(() {
      _notificationCount = 0;
      _pushActivity('Notificaciones revisadas');
      _persistState();
    });
  }

  void _recordSlotRequest(int requested) {
    setState(() {
      _pendingRequests += 1;
      _tab = 2;
      _pushActivity('Solicitud enviada por $requested cupos');
      _persistState();
    });
    _showActionFeedback('Solicitud enviada por $requested cupos.');
  }

  void _recordSale() {
    setState(() {
      _soldToday += 1;
      _pushActivity('Enlace de venta generado');
      _persistState();
    });
    _showActionFeedback('Enlace de venta generado.');
  }

  void _recordValidation() {
    setState(() {
      _validationsDone += 1;
      _pushActivity('Validacion operativa actualizada');
      _persistState();
    });
    _showActionFeedback('Validacion actualizada.');
  }

  void _recordPlan() {
    HapticFeedback.mediumImpact();
    setState(() {
      _pendingRequests += 1;
      _tab = 1;
      _pushActivity('Plan operativo aplicado');
      _persistState();
    });
    _showActionFeedback('Plan agregado al constructor.');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onCreate: _goToCreate,
        onPlanAccepted: _recordPlan,
        notificationCount: _notificationCount,
        onNotificationsOpened: _markNotificationsRead,
      ),
      EventBuilderScreen(resetToken: _newEventToken),
      RequestsScreen(pendingRequests: _pendingRequests),
      OperatorEventsScreen(
        soldToday: _soldToday,
        validationsDone: _validationsDone,
        activity: _activity,
        onCreate: _goToNewEvent,
        onSale: _recordSale,
        onValidation: _recordValidation,
      ),
      MoreScreen(
        activity: _activity,
        onSlotRequest: _recordSlotRequest,
        onValidation: _recordValidation,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _tab, children: pages),
      floatingActionButton: _tab == 2
          ? FloatingActionButton.extended(
              onPressed: _goToCreate,
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.canvasDeep,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _tab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            selectedIcon: Icon(Icons.travel_explore),
            label: 'Radar',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Crear',
          ),
          NavigationDestination(
            icon: Icon(Icons.mark_email_unread_outlined),
            selectedIcon: Icon(Icons.mark_email_unread),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: 'Eventos',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Operar',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onCreate,
    required this.onPlanAccepted,
    required this.notificationCount,
    required this.onNotificationsOpened,
  });

  final VoidCallback onCreate;
  final VoidCallback onPlanAccepted;
  final int notificationCount;
  final VoidCallback onNotificationsOpened;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  String _radarMode = 'eventos';
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Opportunity> get _opportunities {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return opportunities;
    return opportunities.where((item) {
      final haystack = [
        item.title,
        item.description,
        item.categoryLabel,
        item.cluster,
        item.status,
        ...item.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _opportunities;
    final visibleModes = [_radarMode];

    return AppGradientScaffold(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: 'Radar turistico',
              subtitle: '',
              compact: true,
              trailing: HeaderActionCluster(
                notificationCount: widget.notificationCount,
                onNews: () => showTourismNewsCenter(context),
                onNotifications: () {
                  widget.onNotificationsOpened();
                  showNotificationCenter(context);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: RadarModeStrip(
              active: _radarMode,
              onChanged: (value) => setState(() => _radarMode = value),
            ),
          ),
          if (visibleModes.contains('demanda')) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: ClusterGovernancePanel(),
              ),
            ),
          ],
          if (visibleModes.contains('aliados')) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: ClusterPulseSection(),
              ),
            ),
          ],
          if (visibleModes.contains('eventos')) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: RadarSearchField(
                query: _query,
                onChanged: (value) => setState(() => _query = value),
                onClear: () => setState(() => _query = ''),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            const SliverToBoxAdapter(child: SizedBox(height: 4)),
            if (items.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: EmptySearchCard(),
                ),
              ),
            SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: OpportunityCard(
                    item: items[index],
                    onCreate: widget.onCreate,
                  ),
                );
              },
            ),
          ],
          if (visibleModes.contains('finanzas')) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: FinancePulseSection(),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

class ClusterGovernancePanel extends StatefulWidget {
  const ClusterGovernancePanel({super.key});

  @override
  State<ClusterGovernancePanel> createState() => _ClusterGovernancePanelState();
}

class _ClusterGovernancePanelState extends State<ClusterGovernancePanel> {
  late final ClusterGovernance _cluster = tecaigoCluster;
  late final List<ClusterMember> _members = List.of(_cluster.members);
  late final List<ClusterMember> _available = List.of(externalTourOperators);
  late final TextEditingController _clusterName =
      TextEditingController(text: _cluster.name);
  late final TextEditingController _operatorSearch = TextEditingController();
  String _hostId = tecaigoCluster.hostId;
  bool _editingCluster = false;
  final bool _hasHostPermissions = true;

  List<ClusterMember> get _filteredAvailable {
    final query = _operatorSearch.text.trim().toLowerCase();
    if (query.isEmpty) return _available;
    return _available.where((member) {
      return [
        member.name,
        member.role,
        member.capacity,
        member.initials,
      ].join(' ').toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _clusterName.dispose();
    _operatorSearch.dispose();
    super.dispose();
  }

  void _appointHost(ClusterMember member) {
    if (!_hasHostPermissions) return;
    HapticFeedback.selectionClick();
    setState(() => _hostId = member.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${member.name} queda como anfitrion del cluster.')),
    );
  }

  void _addMember(ClusterMember member) {
    if (!_hasHostPermissions) return;
    HapticFeedback.selectionClick();
    setState(() {
      _available.removeWhere((item) => item.id == member.id);
      _members.add(member);
    });
  }

  void _removeMember(ClusterMember member) {
    if (!_hasHostPermissions || member.id == _hostId) return;
    HapticFeedback.selectionClick();
    setState(() {
      _members.removeWhere((item) => item.id == member.id);
      _available.insert(0, member);
    });
  }

  void _resetCluster() {
    if (!_hasHostPermissions) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _clusterName.text = 'Nuevo cluster';
      _members
        ..clear()
        ..add(tecaigoCluster.members.first);
      _available
        ..clear()
        ..addAll([
          ...tecaigoCluster.members.skip(1),
          ...externalTourOperators,
        ]);
      _hostId = tecaigoCluster.members.first.id;
      _operatorSearch.clear();
      _editingCluster = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = _filteredAvailable;

    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _editingCluster
                    ? TextField(
                        controller: _clusterName,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Nombre del cluster',
                        ),
                      )
                    : SectionTitle(
                        title: _clusterName.text,
                        subtitle: _hasHostPermissions
                            ? 'CRUD del cluster e integrantes'
                            : 'Solo el anfitrion puede administrar',
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _hasHostPermissions
                    ? () => setState(() => _editingCluster = !_editingCluster)
                    : null,
                tooltip: _editingCluster ? 'Guardar nombre' : 'Editar cluster',
                icon: Icon(_editingCluster
                    ? Icons.check_rounded
                    : Icons.edit_outlined),
              ),
              PopupMenuButton<String>(
                tooltip: 'Mas acciones',
                onSelected: (value) {
                  if (value == 'new') _resetCluster();
                  if (value == 'delete') {
                    setState(() {
                      _members.removeWhere((member) => member.id != _hostId);
                      _available
                        ..clear()
                        ..addAll([
                          ...tecaigoCluster.members
                              .where((member) => member.id != _hostId),
                          ...externalTourOperators,
                        ]);
                    });
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'new', child: Text('Nuevo cluster')),
                  PopupMenuItem(
                      value: 'delete', child: Text('Vaciar miembros')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _cluster.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _cluster.color.withValues(alpha: 0.28)),
            ),
            child: Row(
              children: [
                IconBadge(icon: _cluster.icon, color: _cluster.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _clusterName.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: _cluster.color, size: 24),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const ClusterListLabel('Integrantes del cluster'),
          const SizedBox(height: 10),
          ..._members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClusterMemberRow(
                member: member,
                color: _cluster.color,
                isHost: member.id == _hostId,
                canManage: _hasHostPermissions,
                onAppoint: () => _appointHost(member),
                onRemove: () => _removeMember(member),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const ClusterListLabel('Tour operadores fuera del cluster'),
          const SizedBox(height: 10),
          OperatorSearchField(
            controller: _operatorSearch,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          if (_available.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                'Todos los operadores disponibles ya estan integrados.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.58)),
              ),
            )
          else if (available.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                'Sin coincidencias para esa busqueda.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.58)),
              ),
            )
          else
            ...available.map(
              (member) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ExternalOperatorRow(
                  member: member,
                  color: _cluster.color,
                  canManage: _hasHostPermissions,
                  onAdd: () => _addMember(member),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ClusterMemberRow extends StatelessWidget {
  const ClusterMemberRow({
    super.key,
    required this.member,
    required this.color,
    required this.isHost,
    required this.canManage,
    required this.onAppoint,
    required this.onRemove,
  });

  final ClusterMember member;
  final Color color;
  final bool isHost;
  final bool canManage;
  final VoidCallback onAppoint;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isHost ? 0.07 : 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHost ? color.withValues(alpha: 0.45) : AppColors.line,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: isHost ? 0.26 : 0.14),
            child: Text(
              member.initials,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: canManage && !isHost ? onAppoint : null,
            tooltip: isHost ? 'Anfitrion actual' : 'Delegar anfitrion',
            icon: Icon(
              isHost
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isHost ? color : Colors.white.withValues(alpha: 0.58),
              size: 24,
            ),
          ),
          if (!isHost)
            IconButton(
              onPressed: canManage ? onRemove : null,
              tooltip: 'Quitar del cluster',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.coral,
                size: 22,
              ),
            )
        ],
      ),
    );
  }
}

class ClusterListLabel extends StatelessWidget {
  const ClusterListLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.72),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class OperatorSearchField extends StatelessWidget {
  const OperatorSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.64), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: 'Buscar tour operador',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w800,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.mint,
            ),
        ],
      ),
    );
  }
}

class ExternalOperatorRow extends StatelessWidget {
  const ExternalOperatorRow({
    super.key,
    required this.member,
    required this.color,
    required this.canManage,
    required this.onAdd,
  });

  final ClusterMember member;
  final Color color;
  final bool canManage;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              member.initials,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: canManage ? onAdd : null,
            tooltip: 'Agregar al cluster',
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class RadarModeStrip extends StatelessWidget {
  const RadarModeStrip(
      {super.key, required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const modes = [
      (
        'eventos',
        'Todos los eventos',
        Icons.event_available_outlined,
        Color(0xFF65C7F7)
      ),
      ('demanda', 'Demanda', Icons.groups_2_outlined, AppColors.teal),
      ('aliados', 'Aliados', Icons.handshake_outlined, AppColors.lime),
      ('finanzas', 'Finanzas', Icons.payments_outlined, AppColors.yellow),
    ];

    return SizedBox(
      height: 46,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: modes.map((mode) {
            final selected = active == mode.$1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Tooltip(
                message: mode.$2,
                child: InkWell(
                  onTap: () => onChanged(mode.$1),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48,
                    height: 46,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint
                          : Colors.white.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.mint
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Icon(
                      mode.$3,
                      size: 21,
                      color: selected ? AppColors.canvasDeep : mode.$4,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class HeaderActionCluster extends StatelessWidget {
  const HeaderActionCluster({
    super.key,
    required this.notificationCount,
    required this.onNews,
    required this.onNotifications,
  });

  final int notificationCount;
  final VoidCallback onNews;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onNews,
          icon: const Icon(Icons.newspaper_rounded),
          tooltip: 'Noticias y tendencias',
        ),
        const SizedBox(width: 6),
        NotificationButton(
            count: notificationCount, onPressed: onNotifications),
      ],
    );
  }
}

class NotificationButton extends StatelessWidget {
  const NotificationButton(
      {super.key, required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notificaciones',
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18),
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.canvas, width: 2),
              ),
              child: Text(
                '$count',
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
          ),
      ],
    );
  }
}

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.045),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, small: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              IconBadge(icon: Icons.history_rounded, color: AppColors.mint),
              SizedBox(width: 12),
              Expanded(
                child: SectionTitle(
                  title: 'Actividad reciente',
                  subtitle: 'Acciones guardadas localmente',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(3).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.lime, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class MetricsStrip extends StatelessWidget {
  const MetricsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: const [
          MetricTile(
            icon: Icons.groups_2_outlined,
            value: '127',
            label: 'demanda activa',
            color: AppColors.mint,
          ),
          MetricTile(
            icon: Icons.handshake_outlined,
            value: '14',
            label: 'alianzas nuevas',
            color: AppColors.lime,
          ),
          MetricTile(
            icon: Icons.event_available_outlined,
            value: '9',
            label: 'eventos listos',
            color: Color(0xFF65C7F7),
          ),
          MetricTile(
            icon: Icons.payments_outlined,
            value: '\$2.8k',
            label: 'venta estimada',
            color: AppColors.yellow,
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.045),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class RadarSearchField extends StatelessWidget {
  const RadarSearchField({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.72), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: const TextStyle(fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: 'Buscar destino, cluster o categoria',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w800,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: query.isEmpty ? null : onClear,
              icon: Icon(
                query.isEmpty ? Icons.tune_rounded : Icons.close_rounded,
                color: AppColors.mint,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.item,
    required this.onCreate,
  });

  final Opportunity item;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showOpportunityDetailSheet(context, item, onCreate),
      borderRadius: BorderRadius.circular(22),
      child: PremiumSurface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 178,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(
                    src: item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.elevated,
                      child: const Icon(Icons.landscape_outlined, size: 36),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x16000000), Color(0xE8061016)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _OpportunityPill(
                      icon: item.icon,
                      text: item.categoryLabel,
                      color: item.feedColor,
                      dark: true,
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _OpportunityPill(
                                    icon: item.feedIcon,
                                    text: item.feedType,
                                    color: item.feedColor,
                                  ),
                                  _OpportunityPill(
                                    text: item.status,
                                    color: item.statusColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.04,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 19,
                          backgroundColor:
                              item.feedColor.withValues(alpha: 0.22),
                          child: Icon(
                            item.feedIcon,
                            color: item.feedColor,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GhostStat(
                          icon: Icons.people_alt_outlined,
                          label: item.demand,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GhostStat(
                          icon: Icons.route_outlined,
                          label: item.cluster,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showOpportunityDetailSheet(
                              context, item, onCreate),
                          icon: const Icon(Icons.article_outlined, size: 16),
                          label: const Text('Detalle'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onCreate,
                          icon: Icon(item.feedType == 'Comercio'
                              ? Icons.storefront_rounded
                              : Icons.add_rounded),
                          label: Text(item.feedType == 'Comercio'
                              ? 'Solicitar'
                              : 'Crear'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor: item.feedColor,
                            foregroundColor: AppColors.canvasDeep,
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
      ),
    );
  }
}

class _OpportunityPill extends StatelessWidget {
  const _OpportunityPill({
    required this.text,
    required this.color,
    this.icon,
    this.dark = false,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withValues(alpha: 0.42)
            : color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: dark ? Colors.white : color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

void showOpportunityDetailSheet(
  BuildContext context,
  Opportunity item,
  VoidCallback onCreate,
) {
  showAppSheet(
    context,
    OpportunityDetailSheet(item: item, onCreate: onCreate),
  );
}

class OpportunityDetailSheet extends StatelessWidget {
  const OpportunityDetailSheet({
    super.key,
    required this.item,
    required this.onCreate,
  });

  final Opportunity item;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: item.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xDD061016)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OpportunityPill(
                          icon: item.feedIcon,
                          text: item.feedType,
                          color: item.feedColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.04,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.tags.map(SoftChip.new).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GhostStat(
                  icon: Icons.people_alt_outlined,
                  label: item.demand,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GhostStat(
                  icon: Icons.route_outlined,
                  label: item.cluster,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cerrar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCreate();
                  },
                  icon: Icon(item.feedType == 'Comercio'
                      ? Icons.storefront_rounded
                      : Icons.add_rounded),
                  label:
                      Text(item.feedType == 'Comercio' ? 'Solicitar' : 'Crear'),
                  style: FilledButton.styleFrom(
                    backgroundColor: item.feedColor,
                    foregroundColor: AppColors.canvasDeep,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventBuilderScreen extends StatefulWidget {
  const EventBuilderScreen({super.key, required this.resetToken});

  final int resetToken;

  @override
  State<EventBuilderScreen> createState() => _EventBuilderScreenState();
}

class _EventBuilderScreenState extends State<EventBuilderScreen> {
  int _capacity = 10;
  int _price = 6;
  int _cost = 5;
  int _commission = 0;
  String _type = 'Playa';
  String _section = 'form';
  String _status = 'Borrador';
  String _saleMode = 'Preventa';
  bool _transport = false;
  bool _food = false;
  bool _guide = false;
  bool _insurance = false;
  bool _publicInventory = false;
  bool _suppressDraftRefresh = false;
  String? _editingId;
  final _name = TextEditingController();
  final _host = TextEditingController();
  final _location = TextEditingController();
  final _date = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _meeting = TextEditingController();
  final _description = TextEditingController();
  final _photoUrl = TextEditingController();
  final _provider = TextEditingController();
  final _notes = TextEditingController();
  final List<EditableEvent> _events = [
    const EditableEvent(
      id: 'demo-1',
      name: 'Ataco Cafe Express',
      type: 'Montana',
      host: 'TeCaiGO Tours',
      location: 'Concepcion de Ataco - Ruta del Cafe',
      imageUrl: 'assets/turismo/ataco.jpeg',
      date: 'Sabado 24 mayo, Domingo 25 mayo, Sabado 31 mayo',
      schedule: '7:30 AM - 4:00 PM',
      capacity: 28,
      price: 38,
      cost: 21,
      commission: 68,
      saleMode: 'Publico',
      status: 'Publicado',
      includes: 'transporte, guia, degustacion de cafe',
      shareInternalFeed: true,
      shareClientFeed: true,
    ),
  ];

  List<TextEditingController> get _draftControllers => [
        _name,
        _host,
        _location,
        _date,
        _start,
        _end,
        _meeting,
        _description,
        _photoUrl,
        _provider,
        _notes,
      ];

  @override
  void initState() {
    super.initState();
    for (final controller in _draftControllers) {
      controller.addListener(_refreshDraftUi);
    }
  }

  @override
  void dispose() {
    for (final controller in _draftControllers) {
      controller.removeListener(_refreshDraftUi);
    }
    _name.dispose();
    _host.dispose();
    _location.dispose();
    _date.dispose();
    _start.dispose();
    _end.dispose();
    _meeting.dispose();
    _description.dispose();
    _photoUrl.dispose();
    _provider.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _refreshDraftUi() {
    if (_suppressDraftRefresh) return;
    if (mounted) setState(() {});
  }

  void _updateDraftControllers(VoidCallback action) {
    _suppressDraftRefresh = true;
    action();
    _suppressDraftRefresh = false;
  }

  @override
  void didUpdateWidget(covariant EventBuilderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetToken != oldWidget.resetToken) {
      _newEvent(notify: false);
    }
  }

  String get _includedText {
    final items = [
      if (_transport) 'transporte',
      if (_food) 'alimentacion',
      if (_guide) 'guia',
      if (_insurance) 'seguro',
      if (_publicInventory) 'venta externa',
    ];
    return items.isEmpty ? 'sin extras' : items.join(', ');
  }

  EditableEvent _draft({String? status}) {
    return EditableEvent(
      id: _editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim().isEmpty ? 'Evento sin nombre' : _name.text.trim(),
      type: _type,
      host:
          _host.text.trim().isEmpty ? 'Anfitrion pendiente' : _host.text.trim(),
      location: _location.text.trim().isEmpty
          ? 'Ubicacion pendiente'
          : _location.text.trim(),
      imageUrl: _photoUrl.text.trim(),
      date: _splitDateOptions(_date.text).isEmpty
          ? 'Fecha pendiente'
          : _splitDateOptions(_date.text).join(', '),
      schedule: '${_start.text.trim()} - ${_end.text.trim()}',
      capacity: _capacity,
      price: _price,
      cost: _cost,
      commission: _commission,
      saleMode: _saleMode,
      status: status ?? _status,
      includes: _includedText,
      shareInternalFeed: status == 'Publicado',
      shareClientFeed: status == 'Publicado',
    );
  }

  void _saveDraft({String status = 'Borrador'}) {
    final event = _draft(status: status);
    setState(() {
      final index = _events.indexWhere((item) => item.id == event.id);
      if (index == -1) {
        _events.insert(0, event);
      } else {
        _events[index] = event;
      }
      _editingId = event.id;
      _status = status;
      _section = 'saved';
    });
    HapticFeedback.mediumImpact();
    _showEventMessage(
        status == 'Publicado' ? 'Evento publicado.' : 'Evento guardado.');
  }

  void _newEvent({bool notify = true}) {
    setState(() {
      _editingId = null;
      _status = 'Borrador';
      _type = 'Playa';
      _saleMode = 'Preventa';
      _capacity = 10;
      _price = 6;
      _cost = 5;
      _commission = 0;
      _transport = false;
      _food = false;
      _guide = false;
      _insurance = false;
      _publicInventory = false;
      _updateDraftControllers(() {
        _name.clear();
        _host.clear();
        _location.clear();
        _date.clear();
        _start.clear();
        _end.clear();
        _meeting.clear();
        _description.clear();
        _photoUrl.clear();
        _provider.clear();
        _notes.clear();
      });
      _section = 'form';
    });
    if (notify) {
      _showEventMessage('Formulario limpio para nuevo evento.');
    }
  }

  void _editEvent(EditableEvent event) {
    setState(() {
      _editingId = event.id;
      _status = event.status;
      _type = event.type;
      _saleMode = event.saleMode;
      _capacity = event.capacity;
      _price = event.price;
      _cost = event.cost;
      _commission = event.commission;
      final parts = event.schedule.split(' - ');
      _updateDraftControllers(() {
        _name.text = event.name;
        _host.text = event.host;
        _location.text = event.location;
        _photoUrl.text = event.imageUrl;
        _date.text = event.date;
        _start.text = parts.isNotEmpty ? parts.first : '8:00 AM';
        _end.text = parts.length > 1 ? parts.last : '5:30 PM';
      });
      _transport = event.includes.contains('transporte');
      _food = event.includes.contains('alimentacion');
      _guide = event.includes.contains('guia');
      _insurance = event.includes.contains('seguro');
      _publicInventory = event.includes.contains('venta externa');
      _section = 'form';
    });
  }

  void _duplicateEvent(EditableEvent event) {
    setState(() {
      _events.insert(
          0,
          event.copyWith(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: '${event.name} copia',
            status: 'Borrador',
            shareInternalFeed: event.shareInternalFeed,
            shareClientFeed: event.shareClientFeed,
          ));
    });
    _showEventMessage('Evento duplicado.');
  }

  void _deleteEvent(EditableEvent event) {
    setState(() {
      _events.removeWhere((item) => item.id == event.id);
      if (_editingId == event.id) {
        _editingId = null;
        _status = 'Borrador';
      }
    });
    _showEventMessage('Evento eliminado.');
  }

  void _showEventMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.panelSoft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Crear experiencia',
            subtitle:
                'CRUD completo para armar, publicar y administrar eventos.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const IconBadge(
                          icon: Icons.event_note_rounded,
                          color: AppColors.mint),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SectionTitle(
                          title: _editingId == null
                              ? 'Nuevo evento'
                              : 'Editando evento',
                          subtitle: _editingId == null
                              ? 'Completa los datos para crearlo'
                              : _status,
                        ),
                      ),
                      if (_editingId != null)
                        IconButton.filledTonal(
                          onPressed: _newEvent,
                          icon: const Icon(Icons.add_rounded),
                          tooltip: 'Nuevo',
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CrudSectionTabs(
                      active: _section,
                      onChanged: (value) => setState(() => _section = value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_section == 'form') ...[
            EventBaseForm(
              type: _type,
              name: _name,
              host: _host,
              location: _location,
              date: _date,
              start: _start,
              end: _end,
              meeting: _meeting,
              description: _description,
              photoUrl: _photoUrl,
              onTypeChanged: (value) => setState(() => _type = value),
            ),
          ] else if (_section == 'params') ...[
            EventParametersForm(
              capacity: _capacity,
              price: _price,
              cost: _cost,
              commission: _commission,
              saleMode: _saleMode,
              transport: _transport,
              food: _food,
              guide: _guide,
              insurance: _insurance,
              publicInventory: _publicInventory,
              provider: _provider,
              notes: _notes,
              onCapacityChanged: (value) =>
                  setState(() => _capacity = value.round()),
              onPriceChanged: (value) {
                setState(() {
                  _price = value.round();
                  if (_cost >= _price) _cost = _price - 1;
                });
              },
              onCostChanged: (value) => setState(() => _cost = value.round()),
              onCommissionChanged: (value) =>
                  setState(() => _commission = value.round()),
              onSaleModeChanged: (value) => setState(() => _saleMode = value),
              onTransportChanged: (value) => setState(() => _transport = value),
              onFoodChanged: (value) => setState(() => _food = value),
              onGuideChanged: (value) => setState(() => _guide = value),
              onInsuranceChanged: (value) => setState(() => _insurance = value),
              onPublicInventoryChanged: (value) =>
                  setState(() => _publicInventory = value),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SectionTitle(
                title: 'Eventos guardados',
                subtitle: '${_events.length} eventos en tu espacio de trabajo',
              ),
            ),
            const SizedBox(height: 10),
            ..._events.map(
              (event) => Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: EditableEventCard(
                  event: event,
                  onEdit: () => _editEvent(event),
                  onDuplicate: () => _duplicateEvent(event),
                  onPublish: () {
                    setState(() {
                      final index =
                          _events.indexWhere((item) => item.id == event.id);
                      if (index != -1)
                        _events[index] = event.copyWith(
                          status: 'Publicado',
                          shareInternalFeed: true,
                          shareClientFeed: true,
                        );
                    });
                    _showEventMessage('Evento publicado.');
                  },
                  onInternalShareChanged: (value) {
                    setState(() {
                      final index =
                          _events.indexWhere((item) => item.id == event.id);
                      if (index != -1) {
                        _events[index] =
                            event.copyWith(shareInternalFeed: value);
                      }
                    });
                  },
                  onClientShareChanged: (value) {
                    setState(() {
                      final index =
                          _events.indexWhere((item) => item.id == event.id);
                      if (index != -1) {
                        _events[index] = event.copyWith(shareClientFeed: value);
                      }
                    });
                  },
                  onDelete: () => _deleteEvent(event),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PremiumSurface(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _saveDraft(),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Guardar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _saveDraft(status: 'Publicado'),
                      icon: const Icon(Icons.publish_rounded, size: 18),
                      label: const Text('Publicar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: AppColors.canvasDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_section != 'saved') ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: SectionTitle(
                title: 'Itinerario sugerido',
                subtitle: 'Editable despues segun proveedor y transporte',
              ),
            ),
            const SizedBox(height: 10),
            const TimelinePreview(),
          ],
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class CrudSectionTabs extends StatelessWidget {
  const CrudSectionTabs(
      {super.key, required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      ('form', 'Datos', Icons.edit_note_rounded),
      ('params', 'Parametros', Icons.tune_rounded),
      ('saved', 'Guardados', Icons.inventory_2_outlined),
    ];

    return Row(
      children: tabs.map((tab) {
        final selected = active == tab.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onChanged(tab.$1),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.tealMist
                      : Colors.white.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppColors.mint.withValues(alpha: 0.45)
                        : AppColors.line,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tab.$3,
                        size: 17,
                        color: selected
                            ? AppColors.mint
                            : Colors.white.withValues(alpha: 0.62)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tab.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class EventReadinessCard extends StatelessWidget {
  const EventReadinessCard({
    super.key,
    required this.complete,
    required this.total,
    required this.status,
  });

  final int complete;
  final int total;
  final String status;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : complete / total;
    final ready = complete == total;
    final color = ready ? AppColors.lime : AppColors.mint;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  ready
                      ? Icons.verified_rounded
                      : Icons.pending_actions_rounded,
                  color: color,
                  size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ready ? 'Listo para publicar' : 'Preparacion del evento',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '$complete/$total',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SoftChip(status),
              SoftChip(ready ? 'Publicable' : 'Faltan datos'),
            ],
          ),
        ],
      ),
    );
  }
}

class EventBaseForm extends StatelessWidget {
  const EventBaseForm({
    super.key,
    required this.type,
    required this.name,
    required this.host,
    required this.location,
    required this.date,
    required this.start,
    required this.end,
    required this.meeting,
    required this.description,
    required this.photoUrl,
    required this.onTypeChanged,
  });

  final String type;
  final TextEditingController name;
  final TextEditingController host;
  final TextEditingController location;
  final TextEditingController date;
  final TextEditingController start;
  final TextEditingController end;
  final TextEditingController meeting;
  final TextEditingController description;
  final TextEditingController photoUrl;
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: PremiumSurface(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Informacion base',
                  subtitle: 'Datos que ve el turista y el operador',
                ),
                const SizedBox(height: 16),
                EventTextField(
                    label: 'Nombre del evento',
                    controller: name,
                    icon: Icons.title_rounded),
                const SizedBox(height: 12),
                EventTextField(
                    label: 'Anfitrion / proveedor',
                    controller: host,
                    icon: Icons.storefront_rounded),
                const SizedBox(height: 12),
                EventTextField(
                    label: 'Ubicacion',
                    controller: location,
                    icon: Icons.place_outlined),
                const SizedBox(height: 12),
                EventTextField(
                    label: 'Descripcion',
                    controller: description,
                    icon: Icons.notes_rounded,
                    maxLines: 3),
                const SizedBox(height: 16),
                EventPhotoPicker(controller: photoUrl),
                const SizedBox(height: 16),
                const Eyebrow('TIPO DE EXPERIENCIA'),
                const SizedBox(height: 8),
                EventTypeChips(value: type, onChanged: onTypeChanged),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: PremiumSurface(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Agenda y punto de encuentro',
                  subtitle: 'Horario, salida y coordinacion del grupo',
                ),
                const SizedBox(height: 16),
                EventTextField(
                    label: 'Fechas disponibles',
                    controller: date,
                    icon: Icons.calendar_month_outlined),
                const SizedBox(height: 7),
                Text(
                  'Separa multiples salidas con coma. Estas fechas alimentan la disponibilidad que ve el turista.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: EventTextField(
                            label: 'Inicio',
                            controller: start,
                            icon: Icons.schedule_rounded)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: EventTextField(
                            label: 'Fin',
                            controller: end,
                            icon: Icons.schedule_send_rounded)),
                  ],
                ),
                const SizedBox(height: 12),
                EventTextField(
                    label: 'Punto de encuentro',
                    controller: meeting,
                    icon: Icons.pin_drop_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EventParametersForm extends StatelessWidget {
  const EventParametersForm({
    super.key,
    required this.capacity,
    required this.price,
    required this.cost,
    required this.commission,
    required this.saleMode,
    required this.transport,
    required this.food,
    required this.guide,
    required this.insurance,
    required this.publicInventory,
    required this.provider,
    required this.notes,
    required this.onCapacityChanged,
    required this.onPriceChanged,
    required this.onCostChanged,
    required this.onCommissionChanged,
    required this.onSaleModeChanged,
    required this.onTransportChanged,
    required this.onFoodChanged,
    required this.onGuideChanged,
    required this.onInsuranceChanged,
    required this.onPublicInventoryChanged,
  });

  final int capacity;
  final int price;
  final int cost;
  final int commission;
  final String saleMode;
  final bool transport;
  final bool food;
  final bool guide;
  final bool insurance;
  final bool publicInventory;
  final TextEditingController provider;
  final TextEditingController notes;
  final ValueChanged<double> onCapacityChanged;
  final ValueChanged<double> onPriceChanged;
  final ValueChanged<double> onCostChanged;
  final ValueChanged<double> onCommissionChanged;
  final ValueChanged<String> onSaleModeChanged;
  final ValueChanged<bool> onTransportChanged;
  final ValueChanged<bool> onFoodChanged;
  final ValueChanged<bool> onGuideChanged;
  final ValueChanged<bool> onInsuranceChanged;
  final ValueChanged<bool> onPublicInventoryChanged;

  @override
  Widget build(BuildContext context) {
    final costMax = (price - 1).clamp(6, 179).toDouble();
    final costValue = cost.clamp(5, costMax.round()).toDouble();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: PremiumSurface(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Parametros comerciales',
                  subtitle: 'Cupos, precio, costo, comision y modo de venta',
                ),
                const SizedBox(height: 16),
                SliderField(
                  label: 'Cupos disponibles',
                  value: capacity.toDouble(),
                  min: 10,
                  max: 120,
                  suffix: '$capacity pax',
                  onChanged: onCapacityChanged,
                ),
                SliderField(
                  label: 'Precio al publico',
                  value: price.toDouble(),
                  min: 10,
                  max: 180,
                  suffix: '\$$price',
                  onChanged: onPriceChanged,
                ),
                SliderField(
                  label: 'Costo operativo',
                  value: costValue,
                  min: 5,
                  max: costMax,
                  suffix: '\$$cost',
                  onChanged: onCostChanged,
                ),
                SliderField(
                  label: 'Comision externa',
                  value: commission.toDouble(),
                  min: 40,
                  max: 85,
                  suffix: '$commission%',
                  onChanged: onCommissionChanged,
                ),
                const SizedBox(height: 8),
                const Eyebrow('MODO DE VENTA'),
                const SizedBox(height: 8),
                EventModeChips(value: saleMode, onChanged: onSaleModeChanged),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: PremiumSurface(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Operacion y validaciones',
                  subtitle: 'Lo que debe estar listo antes de publicar',
                ),
                const SizedBox(height: 14),
                EventToggleRow(
                  icon: Icons.airport_shuttle_rounded,
                  title: 'Transporte incluido',
                  value: transport,
                  onChanged: onTransportChanged,
                ),
                EventToggleRow(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Alimentacion incluida',
                  value: food,
                  onChanged: onFoodChanged,
                ),
                EventToggleRow(
                  icon: Icons.badge_outlined,
                  title: 'Guia certificado',
                  value: guide,
                  onChanged: onGuideChanged,
                ),
                EventToggleRow(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Seguro / contacto emergencia',
                  value: insurance,
                  onChanged: onInsuranceChanged,
                ),
                EventToggleRow(
                  icon: Icons.public_rounded,
                  title: 'Permitir venta externa',
                  value: publicInventory,
                  onChanged: onPublicInventoryChanged,
                ),
                const SizedBox(height: 12),
                EventTextField(
                    label: 'Proveedor clave',
                    controller: provider,
                    icon: Icons.handshake_outlined),
                const SizedBox(height: 12),
                EventTextField(
                    label: 'Notas internas',
                    controller: notes,
                    icon: Icons.sticky_note_2_outlined,
                    maxLines: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EventTextField extends StatelessWidget {
  const EventTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.055),
        alignLabelWithHint: maxLines > 1,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.13)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.mint),
        ),
      ),
    );
  }
}

class EventPhotoPicker extends StatelessWidget {
  const EventPhotoPicker({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = controller.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Foto principal',
          subtitle: 'Imagen de portada para venta y detalle del evento',
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1.75,
            child: hasPhoto
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      TecaigoImage(
                        src: controller.text.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x11000000), Color(0xBB000000)],
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 14,
                        bottom: 12,
                        child:
                            StatusPill(text: 'Portada', color: AppColors.mint),
                      ),
                    ],
                  )
                : const _PhotoPlaceholder(),
          ),
        ),
      ],
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.045),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate_outlined,
              color: AppColors.mint, size: 34),
          const SizedBox(height: 8),
          Text(
            'Agrega una foto de portada',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class EventTypeChips extends StatelessWidget {
  const EventTypeChips(
      {super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['Playa', 'Cafe', 'Lago', 'Montana', 'Pueblo'].map((type) {
        final selected = value == type;
        return ChoiceChip(
          selected: selected,
          label: Text(type),
          onSelected: (_) => onChanged(type),
          selectedColor: AppColors.tealMist,
          labelStyle: TextStyle(
            color:
                selected ? Colors.white : Colors.white.withValues(alpha: 0.74),
            fontWeight: FontWeight.w900,
          ),
        );
      }).toList(),
    );
  }
}

class EventModeChips extends StatelessWidget {
  const EventModeChips(
      {super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['Preventa', 'Publico', 'Privado', 'Cluster'].map((mode) {
        final selected = value == mode;
        return ChoiceChip(
          selected: selected,
          label: Text(mode),
          onSelected: (_) => onChanged(mode),
          selectedColor: AppColors.tealMist,
          labelStyle: TextStyle(
            color:
                selected ? Colors.white : Colors.white.withValues(alpha: 0.74),
            fontWeight: FontWeight.w900,
          ),
        );
      }).toList(),
    );
  }
}

class EventToggleRow extends StatelessWidget {
  const EventToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon,
              color:
                  value ? AppColors.mint : Colors.white.withValues(alpha: 0.45),
              size: 19),
          const SizedBox(width: 10),
          Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class EditableEventCard extends StatelessWidget {
  const EditableEventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDuplicate,
    required this.onPublish,
    required this.onInternalShareChanged,
    required this.onClientShareChanged,
    required this.onDelete,
  });

  final EditableEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onPublish;
  final ValueChanged<bool> onInternalShareChanged;
  final ValueChanged<bool> onClientShareChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color =
        event.status == 'Publicado' ? AppColors.lime : AppColors.yellow;
    return PremiumSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TecaigoImage(
                  src: event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Color(0xEA000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: StatusPill(text: event.status, color: color),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.03,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${event.date} | ${event.schedule}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.type} en ${event.location} con ${event.host}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76), height: 1.3),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: GhostStat(
                            icon: Icons.chair_alt_outlined,
                            label: '${event.capacity} cupos')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: GhostStat(
                            icon: Icons.sell_outlined,
                            label: '\$${event.price} / ${event.saleMode}')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: GhostStat(
                            icon: Icons.percent_rounded,
                            label: '${event.commission}% externo')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: GhostStat(
                            icon: Icons.checklist_rounded,
                            label: event.includes)),
                  ],
                ),
                const SizedBox(height: 14),
                ShareTargetTile(
                  icon: Icons.dynamic_feed_outlined,
                  title: 'Homefeed interno',
                  subtitle: 'Visible para el equipo y aliados operadores',
                  value: event.shareInternalFeed,
                  onChanged: onInternalShareChanged,
                ),
                ShareTargetTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Vista turista',
                  subtitle: 'Disponible para reservar y comprar en la app',
                  value: event.shareClientFeed,
                  onChanged: onClientShareChanged,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.filledTonal(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_rounded),
                        tooltip: 'Editar'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                        onPressed: onDuplicate,
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: 'Duplicar'),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                        onPressed: onPublish,
                        icon: const Icon(Icons.publish_rounded),
                        tooltip: 'Publicar'),
                    const Spacer(),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.coral),
                      tooltip: 'Eliminar',
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
}

class ShareTargetTile extends StatelessWidget {
  const ShareTargetTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: value
            ? AppColors.mint.withValues(alpha: 0.09)
            : Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: value
                ? AppColors.mint.withValues(alpha: 0.32)
                : AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon,
              color:
                  value ? AppColors.mint : Colors.white.withValues(alpha: 0.48),
              size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class EditableEvent {
  const EditableEvent({
    required this.id,
    required this.name,
    required this.type,
    required this.host,
    required this.location,
    required this.imageUrl,
    required this.date,
    required this.schedule,
    required this.capacity,
    required this.price,
    required this.cost,
    required this.commission,
    required this.saleMode,
    required this.status,
    required this.includes,
    required this.shareInternalFeed,
    required this.shareClientFeed,
  });

  final String id;
  final String name;
  final String type;
  final String host;
  final String location;
  final String imageUrl;
  final String date;
  final String schedule;
  final int capacity;
  final int price;
  final int cost;
  final int commission;
  final String saleMode;
  final String status;
  final String includes;
  final bool shareInternalFeed;
  final bool shareClientFeed;

  EditableEvent copyWith({
    String? id,
    String? name,
    String? status,
    bool? shareInternalFeed,
    bool? shareClientFeed,
  }) {
    return EditableEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type,
      host: host,
      location: location,
      imageUrl: imageUrl,
      date: date,
      schedule: schedule,
      capacity: capacity,
      price: price,
      cost: cost,
      commission: commission,
      saleMode: saleMode,
      status: status ?? this.status,
      includes: includes,
      shareInternalFeed: shareInternalFeed ?? this.shareInternalFeed,
      shareClientFeed: shareClientFeed ?? this.shareClientFeed,
    );
  }
}

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key, required this.pendingRequests});

  final int pendingRequests;

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int _segment = 0;
  late final List<ClusterRequest> _items = List.of(requests);

  Color get _filterColor {
    if (_segment == 1) return AppColors.mint;
    if (_segment == 2) return AppColors.yellow;
    return const Color(0xFF65C7F7);
  }

  void _respond(ClusterRequest item, bool approved, {int authorized = 0}) {
    final state = approved ? 'Aprobada' : 'Rechazada';
    final color = approved ? AppColors.lime : AppColors.coral;
    setState(() {
      final index = _items.indexWhere((request) => request.id == item.id);
      if (index != -1) {
        _items[index] = item.copyWith(state: state, color: color);
      }
    });
    if (approved) {
      approvedExternalCupos[_eventInventoryKey(item.event, item.eventDate)] =
          authorized;
    }
    operatorResponseThreads.insert(
      0,
      PriorityThread(
        avatar: item.from
            .split(' ')
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0])
            .join()
            .toUpperCase(),
        sender: item.from,
        subject: '${item.event}: solicitud $state',
        time: 'Ahora',
        unread: true,
        color: color,
      ),
    );
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notificacion enviada a ${item.from}: solicitud $state.',
        ),
      ),
    );
  }

  void _review(ClusterRequest item) {
    showAppSheet(
      context,
      RequestReviewSheet(
        item: item,
        onApprove: (authorized) => _respond(item, true, authorized: authorized),
        onDeny: () => _respond(item, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _items.where((item) {
      if (_segment == 0) return true;
      if (_segment == 1) return item.kind == RequestKind.inbound;
      return item.kind == RequestKind.outbound;
    }).toList();

    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Solicitudes',
            subtitle: '',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: RequestFilterBar(
              value: _segment,
              color: _filterColor,
              onChanged: (value) => setState(() => _segment = value),
            ),
          ),
          const SizedBox(height: 14),
          ...visible.map(
            (item) => Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: RequestCard(
                item: item,
                onReview: () => _review(item),
              ),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class RequestFilterBar extends StatelessWidget {
  const RequestFilterBar({
    super.key,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (0, 'Todo', Icons.inbox_outlined),
      (1, 'Recibidas', Icons.call_received_rounded),
      (2, 'Enviadas', Icons.call_made_rounded),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: items.map((item) {
          final selected = value == item.$1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => onChanged(item.$1),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: 0.26) : null,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? Icons.check_rounded : item.$3,
                        size: 17,
                        color: selected
                            ? color
                            : Colors.white.withValues(alpha: 0.58),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          item.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.68),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.item,
    required this.onReview,
  });

  final ClusterRequest item;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final isInbound = item.kind == RequestKind.inbound;
    final isPending = item.state == 'Pendiente';
    return PremiumSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: AspectRatio(
              aspectRatio: 2.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: item.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xD9061016)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.event,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        StatusPill(text: item.cupos, color: item.color),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(
                      icon: isInbound
                          ? Icons.call_received_rounded
                          : Icons.call_made_rounded,
                      color: item.color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.from,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w900)),
                          Text(
                            item.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.58)),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(text: item.state, color: item.color),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.body,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.35),
                ),
                if (isInbound && isPending) ...[
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: const Text('Revisar solicitud'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: AppColors.mint,
                      foregroundColor: AppColors.canvasDeep,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequestReviewSheet extends StatefulWidget {
  const RequestReviewSheet({
    super.key,
    required this.item,
    required this.onApprove,
    required this.onDeny,
  });

  final ClusterRequest item;
  final ValueChanged<int> onApprove;
  final VoidCallback onDeny;

  @override
  State<RequestReviewSheet> createState() => _RequestReviewSheetState();
}

class _RequestReviewSheetState extends State<RequestReviewSheet> {
  late int _authorized = widget.item.requestedCupos.clamp(1, _available);

  int get _available {
    final free = widget.item.totalCupos -
        widget.item.vendidosInternos -
        widget.item.cuposClusterProtegidos;
    return free.clamp(0, widget.item.totalCupos);
  }

  void _approve() {
    Navigator.of(context).pop();
    widget.onApprove(_authorized);
  }

  void _deny() {
    Navigator.of(context).pop();
    widget.onDeny();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final freeAfter = (_available - _authorized).clamp(0, _available);
    final progress = item.vendidosInternos / item.totalCupos.clamp(1, 999);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 2.2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(src: item.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xDD061016)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Text(
                      item.event,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconBadge(icon: Icons.person_search_rounded, color: item.color),
              const SizedBox(width: 12),
              Expanded(
                child: SectionTitle(
                  title: item.from,
                  subtitle: 'Solicita ${item.requestedCupos} cupos',
                ),
              ),
              StatusPill(text: item.state, color: item.color),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GhostStat(
                  icon: Icons.event_seat_outlined,
                  label: '${item.totalCupos} totales',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GhostStat(
                  icon: Icons.groups_2_outlined,
                  label: '${item.cuposClusterProtegidos} cluster',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GhostStat(
                  icon: Icons.confirmation_number_outlined,
                  label: '${item.vendidosInternos} internos',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GhostStat(
                  icon: Icons.inventory_2_outlined,
                  label: '$_available libres',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 9,
              color: AppColors.mint,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          const SizedBox(height: 16),
          SliderField(
            label: 'Cupos a autorizar',
            value: _authorized.toDouble(),
            min: 1,
            max: _available.clamp(1, 99).toDouble(),
            suffix: '$_authorized cupos',
            onChanged: (value) => setState(() => _authorized = value.round()),
          ),
          Text(
            'Quedarian $freeAfter cupos libres sin tocar los cupos protegidos del cluster.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deny,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Denegar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _available == 0 ? null : _approve,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Autorizar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.canvasDeep,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OperatorEventsScreen extends StatefulWidget {
  const OperatorEventsScreen({
    super.key,
    required this.soldToday,
    required this.validationsDone,
    required this.activity,
    required this.onCreate,
    required this.onSale,
    required this.onValidation,
  });

  final int soldToday;
  final int validationsDone;
  final List<String> activity;
  final VoidCallback onCreate;
  final VoidCallback onSale;
  final VoidCallback onValidation;

  @override
  State<OperatorEventsScreen> createState() => _OperatorEventsScreenState();
}

class _OperatorEventsScreenState extends State<OperatorEventsScreen> {
  EventScope _scope = EventScope.private;
  final Map<String, int> _privateClusterCupos = {};
  final Set<String> _closedEvents = {};
  final Map<String, String> _privateCosts = {};

  @override
  Widget build(BuildContext context) {
    final scopedEvents =
        operatorEvents.where((event) => event.scope == _scope).toList();
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Mis eventos',
            subtitle: 'Control de ventas, cupos y preparacion operativa.',
          ),
          EventScopeMenu(
            selected: _scope,
            onChanged: (scope) => setState(() => _scope = scope),
          ),
          const SizedBox(height: 14),
          ...scopedEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: OperatorEventCard(
                  event: event,
                  clusterAdjustment: _privateClusterCupos[event.title] ?? 0,
                  closed: _closedEvents.contains(event.title),
                  onSale: widget.onSale,
                  onValidation: widget.onValidation,
                  onPrivateManage: () => showPrivateEventControlSheet(
                        context,
                        event,
                        initialClusterCupos:
                            _privateClusterCupos[event.title] ?? 0,
                        initialClosed: _closedEvents.contains(event.title),
                        initialCost: _privateCosts[event.title] ?? '\$42',
                        onSave: (draft) => setState(() {
                          _privateClusterCupos[event.title] =
                              draft.clusterCupos;
                          _privateCosts[event.title] = draft.cost;
                          if (draft.closed) {
                            _closedEvents.add(event.title);
                          } else {
                            _closedEvents.remove(event.title);
                          }
                        }),
                      ),
                  onOccupancyOpen: () => showOccupancySheet(
                        context,
                        event,
                        clusterAdjustment:
                            _privateClusterCupos[event.title] ?? 0,
                      )),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class EventScopeMenu extends StatelessWidget {
  const EventScopeMenu({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final EventScope selected;
  final ValueChanged<EventScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final scopes = [EventScope.private, EventScope.public];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: scopes
            .map(
              (scope) => Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: scope == scopes.last ? 0 : 10),
                  child: EventScopeButton(
                    scope: scope,
                    selected: scope == selected,
                    onTap: () => onChanged(scope),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class EventScopeButton extends StatelessWidget {
  const EventScopeButton({
    super.key,
    required this.scope,
    required this.selected,
    required this.onTap,
  });

  final EventScope scope;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _eventScopeColor(scope);
    return Tooltip(
      message: _eventScopeTitle(scope),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : Colors.white.withValues(alpha: 0.13),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_eventScopeIcon(scope),
                  color: selected ? AppColors.canvasDeep : color, size: 26),
              const SizedBox(height: 7),
              Text(
                _eventScopeTitle(scope),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? AppColors.canvasDeep : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OperatorEventCard extends StatelessWidget {
  const OperatorEventCard({
    super.key,
    required this.event,
    required this.clusterAdjustment,
    required this.closed,
    required this.onSale,
    required this.onValidation,
    required this.onPrivateManage,
    required this.onOccupancyOpen,
  });

  final OperatorEvent event;
  final int clusterAdjustment;
  final bool closed;
  final VoidCallback onSale;
  final VoidCallback onValidation;
  final VoidCallback onPrivateManage;
  final VoidCallback onOccupancyOpen;

  @override
  Widget build(BuildContext context) {
    final externalAuthorized =
        approvedExternalCupos[_eventInventoryKey(event.title, event.date)] ?? 0;
    final protected = event.protectedCupos;
    final tecaigoSold = event.tecaigoSold;
    final internalSold = event.sold + clusterAdjustment;
    final filled = internalSold + externalAuthorized + tecaigoSold;
    final available = (event.capacity -
            internalSold -
            externalAuthorized -
            tecaigoSold -
            protected)
        .clamp(0, event.capacity);
    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.75,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TecaigoImage(
                    src: event.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.elevated,
                      child: Icon(event.icon, color: event.color, size: 36),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x11000000), Color(0xD9000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatusPill(
                                  text: closed ? 'Cerrado' : event.status,
                                  color:
                                      closed ? AppColors.coral : event.color),
                              const SizedBox(height: 8),
                              Text(
                                event.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 24,
                                    height: 1.02,
                                    fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.date,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.black.withValues(alpha: 0.45),
                          child: Icon(event.icon, color: event.color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: GhostStat(
                      icon: _eventScopeIcon(event.scope),
                      label: _eventScopeDetail(event.scope))),
              const SizedBox(width: 10),
              Expanded(
                  child: GhostStat(
                      icon: Icons.place_outlined, label: event.location)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: GhostStat(
                      icon: Icons.groups_2_outlined, label: event.audience)),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onOccupancyOpen,
                  borderRadius: BorderRadius.circular(14),
                  child: GhostStat(
                    icon: Icons.inventory_2_outlined,
                    label: closed ? 'cerrado' : '$available disponibles',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          EventProgressBar(
              sold: filled, capacity: event.capacity, color: event.color),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onOccupancyOpen,
                  borderRadius: BorderRadius.circular(14),
                  child: GhostStat(
                      icon: Icons.confirmation_number_outlined,
                      label: '$internalSold internos'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onOccupancyOpen,
                  borderRadius: BorderRadius.circular(14),
                  child: GhostStat(
                    icon: Icons.handshake_outlined,
                    label: '$externalAuthorized externos',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOccupancyOpen,
                  icon: const Icon(Icons.pie_chart_outline_rounded, size: 18),
                  label: const Text('Conteo'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPrivateManage,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Gestionar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.canvasDeep,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventProgressBar extends StatelessWidget {
  const EventProgressBar({
    super.key,
    required this.sold,
    required this.capacity,
    required this.color,
  });

  final int sold;
  final int capacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = sold / capacity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Progreso de venta',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            color: color,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

void showOccupancySheet(BuildContext context, OperatorEvent event,
    {int clusterAdjustment = 0}) {
  HapticFeedback.selectionClick();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        EventOccupancySheet(event: event, clusterAdjustment: clusterAdjustment),
  );
}

class EventOccupancySheet extends StatelessWidget {
  const EventOccupancySheet(
      {super.key, required this.event, required this.clusterAdjustment});

  final OperatorEvent event;
  final int clusterAdjustment;

  @override
  Widget build(BuildContext context) {
    final externalAuthorized =
        approvedExternalCupos[_eventInventoryKey(event.title, event.date)] ?? 0;
    final tecaigoSold = event.tecaigoSold;
    final internalSold = event.sold + clusterAdjustment;
    final filled = internalSold + externalAuthorized + tecaigoSold;
    final progress = filled / event.capacity;
    final remaining = (event.capacity -
            internalSold -
            externalAuthorized -
            tecaigoSold -
            event.protectedCupos)
        .clamp(0, event.capacity);
    final clusters = _occupancyClusters(event, internalSold: internalSold);
    final members = _occupancyMembers(event);

    return _ClientSheetFrame(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        children: [
          _SheetHandle(),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TecaigoImage(
                    src: event.imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SectionTitle(
                  title: 'Ocupacion del evento',
                  subtitle: event.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PremiumSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$filled/${event.capacity} cupos comprometidos',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                          color: event.color,
                          fontSize: 18,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    color: event.color,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: GhostStat(
                            icon: Icons.event_seat_outlined,
                            label: '$remaining libres')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: GhostStat(
                            icon: Icons.handshake_outlined,
                            label: '$externalAuthorized externos')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: GhostStat(
                            icon: Icons.confirmation_number_outlined,
                            label: '$internalSold internos')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: GhostStat(
                            icon: Icons.storefront_outlined,
                            label: '$tecaigoSold TeCaiGO')),
                  ],
                ),
                const SizedBox(height: 10),
                GhostStat(
                  icon: Icons.hub_outlined,
                  label: '${event.protectedCupos} cupos protegidos del cluster',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(
            title: 'Cupos por cluster',
            subtitle: 'Internos, externos y canal TeCaiGO',
          ),
          const SizedBox(height: 10),
          ...clusters.map(
            (cluster) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClusterOccupancyRow(
                cluster: cluster,
                totalSold: event.sold,
                color: event.color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const SectionTitle(
            title: 'Integrantes',
            subtitle: 'Ventas y reservas asociadas al evento',
          ),
          const SizedBox(height: 10),
          ...members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OccupancyMemberTile(member: member, color: event.color),
            ),
          ),
        ],
      ),
    );
  }
}

class ClusterOccupancyRow extends StatelessWidget {
  const ClusterOccupancyRow({
    super.key,
    required this.cluster,
    required this.totalSold,
    required this.color,
  });

  final OccupancyCluster cluster;
  final int totalSold;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = cluster.count / totalSold.clamp(1, 999);
    return PremiumSurface(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(cluster.icon, color: cluster.color, size: 18),
              const SizedBox(width: 9),
              Expanded(
                child: Text(cluster.name,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
              Text('${cluster.count} cupos',
                  style: TextStyle(
                      color: cluster.color, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: cluster.color,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class OccupancyMemberTile extends StatelessWidget {
  const OccupancyMemberTile({
    super.key,
    required this.member,
    required this.color,
  });

  final OccupancyMember member;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: member.color.withValues(alpha: 0.18),
            child: Text(member.initials,
                style: TextStyle(
                    color: member.color, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  '${member.cluster} - ${member.count} cupos',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          StatusPill(text: member.status, color: member.color),
        ],
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.activity,
    required this.onSlotRequest,
    required this.onValidation,
  });

  final List<String> activity;
  final ValueChanged<int> onSlotRequest;
  final VoidCallback onValidation;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            title: 'Operar',
            subtitle:
                'Validaciones, cupos, finanzas, aliados y correspondencia.',
          ),
          if (activity.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: ActivityPanel(items: activity),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ValidationQueue(onValidation: onValidation),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PublicInventorySection(onSlotRequest: onSlotRequest),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: FinancePulseSection(),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: ClusterPulseSection(),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: CorrespondenceSection(),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: SectionTitle(
              title: 'Modulos',
              subtitle: 'Accesos para crecer la operacion',
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.08,
              ),
              itemBuilder: (context, index) => ModuleTile(item: modules[index]),
            ),
          ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }
}

class ModuleTile extends StatelessWidget {
  const ModuleTile({super.key, required this.item});

  final ModuleItem item;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: item.icon, color: item.color),
          const Spacer(),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class ValidationQueue extends StatelessWidget {
  const ValidationQueue({super.key, required this.onValidation});

  final VoidCallback onValidation;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              IconBadge(icon: Icons.verified_outlined, color: AppColors.lime),
              SizedBox(width: 12),
              Expanded(
                child: SectionTitle(
                  title: 'Validaciones pendientes',
                  subtitle: 'Bloqueos antes de publicar',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...validationItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ValidationRow(item: item, onValidation: onValidation),
            ),
          ),
        ],
      ),
    );
  }
}

class ValidationRow extends StatelessWidget {
  const ValidationRow({super.key, required this.item, this.onValidation});

  final ValidationItem item;
  final VoidCallback? onValidation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(
              item.done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: item.done ? AppColors.lime : AppColors.yellow),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(
                  item.context,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.56),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () =>
                showValidationItemSheet(context, item, onValidation),
            child: Text(item.done ? 'Ver' : 'Resolver'),
          ),
        ],
      ),
    );
  }
}

class PublicInventorySection extends StatelessWidget {
  const PublicInventorySection({super.key, required this.onSlotRequest});

  final ValueChanged<int> onSlotRequest;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Eventos publicos',
            subtitle: 'Cupos disponibles para venta externa',
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 178,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: publicSlots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => PublicSlotCard(
                slot: publicSlots[index],
                onSlotRequest: onSlotRequest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PublicSlotCard extends StatelessWidget {
  const PublicSlotCard(
      {super.key, required this.slot, required this.onSlotRequest});

  final PublicSlot slot;
  final ValueChanged<int> onSlotRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            slot.color.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0.045),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: slot.color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: slot.icon, color: slot.color, small: true),
              const Spacer(),
              StatusPill(text: slot.free, color: slot.color),
            ],
          ),
          const Spacer(),
          Text(
            slot.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            slot.host,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58), fontSize: 12),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => showSlotRequestSheet(context, slot, onSlotRequest),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(36),
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.canvasDeep,
            ),
            child: const Text('Solicitar cupos'),
          ),
        ],
      ),
    );
  }
}

class FinancePulseSection extends StatelessWidget {
  const FinancePulseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              IconBadge(icon: Icons.payments_outlined, color: AppColors.yellow),
              SizedBox(width: 12),
              Expanded(
                child: SectionTitle(
                  title: 'Finanzas',
                  subtitle: 'Margen, preventa y liquidaciones',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: MiniKpi(label: 'Preventa', value: '\$2.8k')),
              SizedBox(width: 10),
              Expanded(child: MiniKpi(label: 'Comision', value: '\$740')),
              SizedBox(width: 10),
              Expanded(child: MiniKpi(label: 'Pendiente', value: '\$410')),
            ],
          ),
          const SizedBox(height: 16),
          ...financeMovements.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FinanceMovementRow(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class FinanceMovementRow extends StatelessWidget {
  const FinanceMovementRow({super.key, required this.item});

  final FinanceMovement item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconBadge(icon: item.icon, color: item.color, small: true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          item.amount,
          style: TextStyle(color: item.color, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class ClusterPulseSection extends StatefulWidget {
  const ClusterPulseSection({super.key});

  @override
  State<ClusterPulseSection> createState() => _ClusterPulseSectionState();
}

class _ClusterPulseSectionState extends State<ClusterPulseSection> {
  late final List<DepartureLocation> _locations =
      List.of(seedDepartureLocations);
  String _recommendedId = seedDepartureLocations.first.id;

  void _upsert(DepartureLocation location) {
    setState(() {
      final index = _locations.indexWhere((item) => item.id == location.id);
      if (index == -1) {
        _locations.insert(0, location);
      } else {
        _locations[index] = location;
      }
    });
  }

  void _delete(DepartureLocation location) {
    setState(() {
      _locations.removeWhere((item) => item.id == location.id);
      if (_recommendedId == location.id && _locations.isNotEmpty) {
        _recommendedId = _locations.first.id;
      }
    });
  }

  void _openEditor([DepartureLocation? location]) {
    showAppSheet(
      context,
      DepartureLocationEditor(
        location: location,
        onSave: _upsert,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionTitle(
                  title: 'Lugares de salida',
                  subtitle: 'Mantenimiento para eventos del anfitrion',
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => _openEditor(),
                tooltip: 'Agregar salida',
                icon: const Icon(Icons.add_location_alt_outlined),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._locations.map(
            (location) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DepartureLocationRow(
                location: location,
                selected: _recommendedId == location.id,
                onSelect: () => setState(() => _recommendedId = location.id),
                onEdit: () => _openEditor(location),
                onDelete: () => _delete(location),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DepartureLocationRow extends StatelessWidget {
  const DepartureLocationRow({
    super.key,
    required this.location,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final DepartureLocation location;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.mint.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? AppColors.mint.withValues(alpha: 0.42)
              : AppColors.line,
        ),
      ),
      child: Row(
        children: [
          IconBadge(icon: location.icon, color: AppColors.mint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  location.reference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.56),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSelect,
            tooltip: selected ? 'Salida sugerida' : 'Marcar como sugerida',
            icon: Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? AppColors.mint
                  : Colors.white.withValues(alpha: 0.58),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Editar salida',
            icon: const Icon(Icons.edit_outlined, size: 21),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Borrar salida',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.coral,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class DepartureLocationEditor extends StatefulWidget {
  const DepartureLocationEditor({
    super.key,
    required this.onSave,
    this.location,
  });

  final DepartureLocation? location;
  final ValueChanged<DepartureLocation> onSave;

  @override
  State<DepartureLocationEditor> createState() =>
      _DepartureLocationEditorState();
}

class _DepartureLocationEditorState extends State<DepartureLocationEditor> {
  late final TextEditingController _name =
      TextEditingController(text: widget.location?.name ?? '');
  late final TextEditingController _reference =
      TextEditingController(text: widget.location?.reference ?? '');
  late final TextEditingController _window =
      TextEditingController(text: widget.location?.window ?? '');

  @override
  void dispose() {
    _name.dispose();
    _reference.dispose();
    _window.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    widget.onSave(
      DepartureLocation(
        id: widget.location?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        reference: _reference.text.trim().isEmpty
            ? 'Referencia pendiente'
            : _reference.text.trim(),
        window: _window.text.trim().isEmpty
            ? 'Horario flexible'
            : _window.text.trim(),
        icon: widget.location?.icon ?? Icons.location_on_outlined,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          SectionTitle(
            title: widget.location == null ? 'Nueva salida' : 'Editar salida',
            subtitle: 'Punto que el anfitrion podra elegir al crear eventos',
          ),
          const SizedBox(height: 14),
          EventTextField(
              label: 'Lugar',
              controller: _name,
              icon: Icons.location_on_outlined),
          const SizedBox(height: 10),
          EventTextField(
              label: 'Referencia',
              controller: _reference,
              icon: Icons.place_outlined),
          const SizedBox(height: 10),
          EventTextField(
              label: 'Horario recomendado',
              controller: _window,
              icon: Icons.schedule_outlined),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar salida'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.canvasDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class CorrespondenceSection extends StatefulWidget {
  const CorrespondenceSection({super.key});

  @override
  State<CorrespondenceSection> createState() => _CorrespondenceSectionState();
}

class _CorrespondenceSectionState extends State<CorrespondenceSection> {
  String _filter = 'inbox';
  final List<CorrespondenceRecord> _items = [
    const CorrespondenceRecord(
      id: 'mail-1',
      avatar: 'GO',
      contact: 'Gastro Occidente',
      subject: 'Menus disponibles para Ataco',
      body:
          'Tenemos disponibilidad para recibir grupos pequenos desde este fin de semana.',
      time: '10:12',
      folder: 'inbox',
      status: 'Nuevo',
      priority: 'Alta',
      opportunity: 'Proveedor',
      color: AppColors.mint,
    ),
    const CorrespondenceRecord(
      id: 'mail-2',
      avatar: 'SC',
      contact: 'Shuttle Centroamerica',
      subject: '8 unidades disponibles para Rio Dulce y Semuc',
      body:
          'Podemos confirmar vans con chofer y seguro si se bloquean antes del viernes.',
      time: '09:40',
      folder: 'follow',
      status: 'Seguimiento',
      priority: 'Alta',
      opportunity: 'Transporte',
      color: AppColors.lime,
    ),
    const CorrespondenceRecord(
      id: 'mail-3',
      avatar: 'UN',
      contact: 'Universidad Turismo',
      subject: '28 estudiantes disponibles para practicas',
      body:
          'Buscamos experiencias de campo para estudiantes de turismo y hospitalidad.',
      time: '09:05',
      folder: 'sent',
      status: 'Respondido',
      priority: 'Media',
      opportunity: 'Demanda',
      color: const Color(0xFF65C7F7),
    ),
  ];

  List<CorrespondenceRecord> get _visibleItems {
    if (_filter == 'all') return _items;
    return _items.where((item) => item.folder == _filter).toList();
  }

  int get _unread => _items.where((item) => item.status == 'Nuevo').length;
  int get _follow => _items.where((item) => item.folder == 'follow').length;

  void _upsert(CorrespondenceRecord record) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == record.id);
      if (index == -1) {
        _items.insert(0, record);
      } else {
        _items[index] = record;
      }
    });
    _toast(record.folder == 'draft'
        ? 'Borrador guardado.'
        : 'Correspondencia guardada.');
  }

  void _duplicate(CorrespondenceRecord record) {
    setState(() {
      _items.insert(
          0,
          record.copyWith(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            subject: '${record.subject} copia',
            folder: 'draft',
            status: 'Borrador',
          ));
    });
    _toast('Correspondencia duplicada.');
  }

  void _delete(CorrespondenceRecord record) {
    setState(() => _items.removeWhere((item) => item.id == record.id));
    _toast('Correspondencia eliminada.');
  }

  void _mark(CorrespondenceRecord record, String folder, String status) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == record.id);
      if (index != -1)
        _items[index] = record.copyWith(folder: folder, status: status);
    });
    _toast(status == 'Respondido'
        ? 'Marcado como respondido.'
        : 'Marcado para seguimiento.');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.panelSoft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;
    return PremiumSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(
                  icon: Icons.forward_to_inbox_outlined, color: AppColors.mint),
              const SizedBox(width: 12),
              const Expanded(
                child: SectionTitle(
                  title: 'Correspondencia',
                  subtitle: 'CRUD de mensajes comerciales',
                ),
              ),
              IconButton.filledTonal(
                onPressed: () =>
                    showCorrespondenceEditor(context, onSave: _upsert),
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Nueva correspondencia',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: MiniKpi(label: 'Nuevos', value: '$_unread')),
              const SizedBox(width: 10),
              Expanded(child: MiniKpi(label: 'Seguimiento', value: '$_follow')),
              const SizedBox(width: 10),
              Expanded(
                  child: MiniKpi(label: 'Total', value: '${_items.length}')),
            ],
          ),
          const SizedBox(height: 14),
          CorrespondenceFilters(
              active: _filter,
              onChanged: (value) => setState(() => _filter = value)),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                'No hay mensajes en esta bandeja.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w800),
              ),
            )
          else
            ...visible.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CorrespondenceCard(
                  record: record,
                  onEdit: () => showCorrespondenceEditor(context,
                      record: record, onSave: _upsert),
                  onDuplicate: () => _duplicate(record),
                  onFollow: () => _mark(record, 'follow', 'Seguimiento'),
                  onReply: () => _mark(record, 'sent', 'Respondido'),
                  onDelete: () => _delete(record),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CorrespondenceFilters extends StatelessWidget {
  const CorrespondenceFilters(
      {super.key, required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('inbox', 'Entrada'),
      ('follow', 'Seguir'),
      ('draft', 'Borrador'),
      ('sent', 'Enviada'),
      ('all', 'Todo'),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filters[index];
          final selected = active == item.$1;
          return ChoiceChip(
            selected: selected,
            label: Text(item.$2),
            onSelected: (_) => onChanged(item.$1),
            selectedColor: AppColors.tealMist,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          );
        },
      ),
    );
  }
}

class CorrespondenceCard extends StatelessWidget {
  const CorrespondenceCard({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDuplicate,
    required this.onFollow,
    required this.onReply,
    required this.onDelete,
  });

  final CorrespondenceRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onFollow;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: record.status == 'Nuevo'
            ? AppColors.tealMist
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: record.status == 'Nuevo'
              ? AppColors.mint.withValues(alpha: 0.24)
              : AppColors.line,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: record.color.withValues(alpha: 0.22),
                child: Text(record.avatar,
                    style: TextStyle(
                        color: record.color, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.contact,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          record.time,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.48),
                              fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62), height: 1.3),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StatusPill(text: record.status, color: record.color),
              const SizedBox(width: 8),
              StatusPill(
                  text: record.priority,
                  color: record.priority == 'Alta'
                      ? AppColors.coral
                      : AppColors.yellow),
              const SizedBox(width: 8),
              Expanded(
                  child: GhostStat(
                      icon: Icons.work_outline_rounded,
                      label: record.opportunity)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filledTonal(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Editar'),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                  onPressed: onDuplicate,
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: 'Duplicar'),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                  onPressed: onFollow,
                  icon: const Icon(Icons.flag_outlined),
                  tooltip: 'Seguimiento'),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                  onPressed: onReply,
                  icon: const Icon(Icons.reply_rounded),
                  tooltip: 'Responder'),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.coral),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThreadRow extends StatelessWidget {
  const ThreadRow({super.key, required this.thread});

  final PriorityThread thread;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => showThreadSheet(context, thread),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: thread.unread
              ? AppColors.tealMist
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: thread.unread
                ? AppColors.mint.withValues(alpha: 0.24)
                : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: thread.color.withValues(alpha: 0.22),
              child: Text(thread.avatar,
                  style: TextStyle(
                      color: thread.color, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.sender,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        thread.time,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.48),
                            fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    thread.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showAppSheet(BuildContext context, Widget child) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PremiumSurface(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ),
      );
    },
  );
}

void showNotificationCenter(BuildContext context) {
  showAppSheet(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        const SectionTitle(
          title: 'Notificaciones',
          subtitle: 'Alertas que requieren accion del operador',
        ),
        const SizedBox(height: 16),
        ...operatorResponseThreads.map(
          (thread) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ThreadRow(thread: thread),
          ),
        ),
        ...priorityThreads.map(
          (thread) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ThreadRow(thread: thread),
          ),
        ),
      ],
    ),
  );
}

void showTourismNewsCenter(BuildContext context) {
  showAppSheet(
    context,
    const TourismNewsSheet(),
  );
}

void showSalesProductSheet(BuildContext context, SalesProduct product) {
  showAppSheet(
    context,
    SalesProductDetailSheet(product: product),
  );
}

class SalesProductDetailSheet extends StatelessWidget {
  const SalesProductDetailSheet({super.key, required this.product});

  final SalesProduct product;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TecaigoImage(src: product.imageUrl, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Color(0xEE000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: StatusPill(text: product.kind, color: product.color),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    child: Icon(_salesProductIcon(product.kind),
                        color: product.color),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 26,
                        height: 1.02,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          product.subtitle,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.32,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: GhostStat(
                    icon: Icons.payments_outlined, label: product.price)),
            const SizedBox(width: 10),
            Expanded(
                child: GhostStat(
                    icon: Icons.verified_user_outlined,
                    label: 'Compra segura')),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Reservar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text('Comprar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: AppColors.canvasDeep,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TourismNewsSheet extends StatelessWidget {
  const TourismNewsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const news = [
      TourismNewsItem(
        title: 'Familias buscan planes cortos de fin de semana',
        subtitle:
            'Sube el interes por volcanes, pueblos y rutas con comida incluida.',
        tag: 'Consumo',
        icon: Icons.family_restroom_rounded,
        color: AppColors.mint,
      ),
      TourismNewsItem(
        title: 'El Tunco y Rio Dulce empujan paquetes regionales',
        subtitle:
            'Agencias estan combinando castillo, playa y rutas naturales para grupos.',
        tag: 'Regional',
        icon: Icons.trending_up_rounded,
        color: Color(0xFF65C7F7),
      ),
      TourismNewsItem(
        title: 'Mayor conversion cuando hay foto real y fecha clara',
        subtitle:
            'Eventos con portada, cupos visibles y salidas multiples venden mejor.',
        tag: 'Venta',
        icon: Icons.photo_camera_outlined,
        color: AppColors.lime,
      ),
      TourismNewsItem(
        title: 'Comercios con capacidad publicada reciben mas solicitudes',
        subtitle: 'Operadores filtran aliados por cupos, horario y ubicacion.',
        tag: 'Aliados',
        icon: Icons.storefront_rounded,
        color: AppColors.yellow,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        const SectionTitle(
          title: 'Noticias y tendencias',
          subtitle: 'Senales de consumo turistico para decidir que vender.',
        ),
        const SizedBox(height: 16),
        ...news.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TourismNewsTile(item: item),
          ),
        ),
      ],
    );
  }
}

class TourismNewsItem {
  const TourismNewsItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final Color color;
}

class TourismNewsTile extends StatelessWidget {
  const TourismNewsTile({super.key, required this.item});

  final TourismNewsItem item;

  @override
  Widget build(BuildContext context) {
    return PremiumSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconBadge(icon: item.icon, color: item.color, small: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(text: item.tag, color: item.color),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  item.subtitle,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      height: 1.28,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showSlotRequestSheet(
    BuildContext context, PublicSlot slot, ValueChanged<int> onSlotRequest) {
  showAppSheet(
    context,
    SlotRequestSheet(slot: slot, onSlotRequest: onSlotRequest),
  );
}

void showValidationSheet(
    BuildContext context, OperatorEvent event, VoidCallback onValidation) {
  showAppSheet(
    context,
    EventValidationSheet(event: event, onValidation: onValidation),
  );
}

void showSellSheet(
    BuildContext context, OperatorEvent event, VoidCallback onSale) {
  showAppSheet(
    context,
    SellSheet(event: event, onSale: onSale),
  );
}

void showPrivateEventControlSheet(
  BuildContext context,
  OperatorEvent event, {
  required int initialClusterCupos,
  required bool initialClosed,
  required String initialCost,
  required ValueChanged<PrivateEventDraft> onSave,
}) {
  showAppSheet(
    context,
    PrivateEventControlSheet(
      event: event,
      initialClusterCupos: initialClusterCupos,
      initialClosed: initialClosed,
      initialCost: initialCost,
      onSave: onSave,
    ),
  );
}

void showValidationItemSheet(
    BuildContext context, ValidationItem item, VoidCallback? onValidation) {
  showAppSheet(
    context,
    ValidationItemSheet(item: item, onValidation: onValidation),
  );
}

void showThreadSheet(BuildContext context, PriorityThread thread) {
  showAppSheet(
    context,
    ThreadDetailSheet(thread: thread),
  );
}

void showCorrespondenceEditor(
  BuildContext context, {
  CorrespondenceRecord? record,
  required ValueChanged<CorrespondenceRecord> onSave,
}) {
  showAppSheet(
    context,
    CorrespondenceEditorSheet(record: record, onSave: onSave),
  );
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.26),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class SlotRequestSheet extends StatefulWidget {
  const SlotRequestSheet(
      {super.key, required this.slot, required this.onSlotRequest});

  final PublicSlot slot;
  final ValueChanged<int> onSlotRequest;

  @override
  State<SlotRequestSheet> createState() => _SlotRequestSheetState();
}

class _SlotRequestSheetState extends State<SlotRequestSheet> {
  int _requested = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        Row(
          children: [
            IconBadge(icon: widget.slot.icon, color: widget.slot.color),
            const SizedBox(width: 12),
            Expanded(
              child: SectionTitle(
                title: widget.slot.title,
                subtitle: widget.slot.host,
              ),
            ),
            StatusPill(text: widget.slot.free, color: widget.slot.color),
          ],
        ),
        const SizedBox(height: 18),
        const NativeInput(
            label: 'Comision propuesta', value: '70% para operador externo'),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(
                child: Text('Cupos a solicitar',
                    style: TextStyle(fontWeight: FontWeight.w900))),
            IconButton.filledTonal(
              onPressed: () =>
                  setState(() => _requested = (_requested - 1).clamp(1, 18)),
              icon: const Icon(Icons.remove_rounded),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('$_requested',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900)),
            ),
            IconButton.filledTonal(
              onPressed: () =>
                  setState(() => _requested = (_requested + 1).clamp(1, 18)),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            widget.onSlotRequest(_requested);
          },
          icon: const Icon(Icons.send_rounded),
          label: const Text('Enviar solicitud de cupos'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class EventValidationSheet extends StatelessWidget {
  const EventValidationSheet(
      {super.key, required this.event, required this.onValidation});

  final OperatorEvent event;
  final VoidCallback onValidation;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        SectionTitle(title: 'Checklist operativo', subtitle: event.title),
        const SizedBox(height: 16),
        const ValidationRow(
          item: ValidationItem(
            title: 'Transporte confirmado',
            context: 'Proveedor asignado y horario validado',
            done: true,
          ),
        ),
        const SizedBox(height: 10),
        const ValidationRow(
          item: ValidationItem(
            title: 'Contacto de emergencia',
            context: 'Falta telefono del responsable en destino',
            done: false,
          ),
        ),
        const SizedBox(height: 10),
        const ValidationRow(
          item: ValidationItem(
            title: 'Lista de pasajeros',
            context: 'Sincronizada con preventa',
            done: true,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onValidation();
          },
          icon: const Icon(Icons.task_alt_rounded),
          label: const Text('Actualizar validacion'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class SellSheet extends StatelessWidget {
  const SellSheet({super.key, required this.event, required this.onSale});

  final OperatorEvent event;
  final VoidCallback onSale;

  @override
  Widget build(BuildContext context) {
    final remaining = event.capacity - event.sold;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        SectionTitle(title: 'Venta rapida', subtitle: event.title),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: MiniKpi(label: 'Disponibles', value: '$remaining')),
            const SizedBox(width: 10),
            const Expanded(child: MiniKpi(label: 'Precio', value: '\$42')),
            const SizedBox(width: 10),
            const Expanded(child: MiniKpi(label: 'Comision', value: '18%')),
          ],
        ),
        const SizedBox(height: 16),
        const NativeInput(label: 'Canal', value: 'Cartera propia / WhatsApp'),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onSale();
          },
          icon: const Icon(Icons.link_rounded),
          label: const Text('Generar enlace de venta'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class PrivateEventDraft {
  const PrivateEventDraft({
    required this.clusterCupos,
    required this.cost,
    required this.closed,
  });

  final int clusterCupos;
  final String cost;
  final bool closed;
}

class PrivateEventControlSheet extends StatefulWidget {
  const PrivateEventControlSheet({
    super.key,
    required this.event,
    required this.initialClusterCupos,
    required this.initialClosed,
    required this.initialCost,
    required this.onSave,
  });

  final OperatorEvent event;
  final int initialClusterCupos;
  final bool initialClosed;
  final String initialCost;
  final ValueChanged<PrivateEventDraft> onSave;

  @override
  State<PrivateEventControlSheet> createState() =>
      _PrivateEventControlSheetState();
}

class _PrivateEventControlSheetState extends State<PrivateEventControlSheet> {
  late int _clusterCupos;
  late bool _closed;
  late final TextEditingController _costController;

  int get _externalAuthorized =>
      approvedExternalCupos[
          _eventInventoryKey(widget.event.title, widget.event.date)] ??
      0;

  int get _maxClusterCupos => (widget.event.capacity -
          widget.event.sold -
          _externalAuthorized -
          widget.event.tecaigoSold -
          widget.event.protectedCupos)
      .clamp(0, widget.event.capacity);

  int get _internalSold => widget.event.sold + _clusterCupos;

  int get _available => (widget.event.capacity -
          _internalSold -
          _externalAuthorized -
          widget.event.tecaigoSold -
          widget.event.protectedCupos)
      .clamp(0, widget.event.capacity);

  @override
  void initState() {
    super.initState();
    _clusterCupos = widget.initialClusterCupos.clamp(0, _maxClusterCupos);
    _closed = widget.initialClosed;
    _costController = TextEditingController(text: widget.initialCost);
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  void _changeCupos(int delta) {
    setState(() {
      _clusterCupos = (_clusterCupos + delta).clamp(0, _maxClusterCupos);
    });
  }

  void _save() {
    widget.onSave(
      PrivateEventDraft(
        clusterCupos: _clusterCupos,
        cost: _costController.text.trim().isEmpty
            ? '\$42'
            : _costController.text.trim(),
        closed: _closed,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final filled =
        _internalSold + _externalAuthorized + widget.event.tecaigoSold;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        Row(
          children: [
            IconBadge(icon: Icons.lock_rounded, color: widget.event.color),
            const SizedBox(width: 12),
            Expanded(
              child: SectionTitle(
                title: widget.event.scope == EventScope.private
                    ? 'Gestion privada'
                    : 'Gestion publica',
                subtitle: widget.event.title,
              ),
            ),
            StatusPill(
                text: _closed ? 'Cerrado' : 'Anfitrion',
                color: _closed ? AppColors.coral : widget.event.color),
          ],
        ),
        const SizedBox(height: 16),
        EventProgressBar(
            sold: filled,
            capacity: widget.event.capacity,
            color: widget.event.color),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: GhostStat(
                    icon: Icons.groups_2_outlined,
                    label: '$_internalSold cluster')),
            const SizedBox(width: 10),
            Expanded(
                child: GhostStat(
                    icon: Icons.storefront_outlined,
                    label: '${widget.event.tecaigoSold} TeCaiGO')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: GhostStat(
                    icon: Icons.inventory_2_outlined,
                    label: '$_available disponibles')),
            const SizedBox(width: 10),
            Expanded(
                child: GhostStat(
                    icon: Icons.hub_outlined,
                    label: '${widget.event.protectedCupos} protegidos')),
          ],
        ),
        const SizedBox(height: 16),
        PremiumSurface(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Cupos\ncluster',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      height: 1.05,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70),
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton.filledTonal(
                  onPressed: _clusterCupos == 0 ? null : () => _changeCupos(-1),
                  icon: const Icon(Icons.remove_rounded, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                width: 68,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('$_clusterCupos',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton.filled(
                  onPressed: _available == 0 ? null : () => _changeCupos(1),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _costController,
          keyboardType: TextInputType.text,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            labelText: 'Costo / precio publico',
            prefixIcon: const Icon(Icons.attach_money_rounded),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: widget.event.color),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          value: _closed,
          onChanged: (value) => setState(() => _closed = value),
          contentPadding: EdgeInsets.zero,
          title: const Text('Cerrar evento',
              style: TextStyle(fontWeight: FontWeight.w900)),
          subtitle: const Text(
              'Bloquea nuevas asignaciones y conserva el conteo actual.'),
          activeThumbColor: AppColors.coral,
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Guardar cambios'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class ValidationItemSheet extends StatelessWidget {
  const ValidationItemSheet({super.key, required this.item, this.onValidation});

  final ValidationItem item;
  final VoidCallback? onValidation;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        SectionTitle(title: item.title, subtitle: item.context),
        const SizedBox(height: 16),
        GhostStat(
          icon: item.done
              ? Icons.check_circle_rounded
              : Icons.warning_amber_rounded,
          label: item.done
              ? 'Validacion completada'
              : 'Requiere accion antes de publicar',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            if (!item.done) {
              onValidation?.call();
            }
          },
          icon: Icon(
              item.done ? Icons.visibility_rounded : Icons.task_alt_rounded),
          label: Text(item.done ? 'Ver evidencia' : 'Marcar como resuelto'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: AppColors.mint,
            foregroundColor: AppColors.canvasDeep,
          ),
        ),
      ],
    );
  }
}

class CorrespondenceEditorSheet extends StatefulWidget {
  const CorrespondenceEditorSheet(
      {super.key, this.record, required this.onSave});

  final CorrespondenceRecord? record;
  final ValueChanged<CorrespondenceRecord> onSave;

  @override
  State<CorrespondenceEditorSheet> createState() =>
      _CorrespondenceEditorSheetState();
}

class _CorrespondenceEditorSheetState extends State<CorrespondenceEditorSheet> {
  late final TextEditingController _contact;
  late final TextEditingController _subject;
  late final TextEditingController _body;
  late String _folder;
  late String _priority;
  late String _opportunity;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _contact = TextEditingController(text: record?.contact ?? 'Nuevo aliado');
    _subject = TextEditingController(
        text: record?.subject ?? 'Propuesta para nuevo evento');
    _body = TextEditingController(
      text: record?.body ??
          'Detalle de disponibilidad, condiciones comerciales y siguiente paso operativo.',
    );
    _folder = record?.folder ?? 'draft';
    _priority = record?.priority ?? 'Media';
    _opportunity = record?.opportunity ?? 'Proveedor';
  }

  @override
  void dispose() {
    _contact.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save({required bool send}) {
    final source = widget.record;
    final contact = _contact.text.trim().isEmpty
        ? 'Contacto pendiente'
        : _contact.text.trim();
    final record = CorrespondenceRecord(
      id: source?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      avatar: _avatarFor(contact),
      contact: contact,
      subject:
          _subject.text.trim().isEmpty ? 'Sin asunto' : _subject.text.trim(),
      body: _body.text.trim().isEmpty ? 'Sin detalle' : _body.text.trim(),
      time: 'Ahora',
      folder: send ? 'sent' : _folder,
      status: send
          ? 'Respondido'
          : (_folder == 'draft' ? 'Borrador' : 'Seguimiento'),
      priority: _priority,
      opportunity: _opportunity,
      color: _priority == 'Alta' ? AppColors.coral : AppColors.mint,
    );
    widget.onSave(record);
    Navigator.pop(context);
  }

  String _avatarFor(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1)
      return parts.first.characters.take(2).toString().toUpperCase();
    return '${parts[0].characters.first}${parts[1].characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          SectionTitle(
            title: widget.record == null
                ? 'Nueva correspondencia'
                : 'Editar correspondencia',
            subtitle: 'Mensaje, estado y oportunidad comercial',
          ),
          const SizedBox(height: 16),
          EventTextField(
              label: 'Contacto / organizacion',
              controller: _contact,
              icon: Icons.account_circle_outlined),
          const SizedBox(height: 12),
          EventTextField(
              label: 'Asunto',
              controller: _subject,
              icon: Icons.subject_rounded),
          const SizedBox(height: 12),
          EventTextField(
              label: 'Mensaje',
              controller: _body,
              icon: Icons.mail_outline_rounded,
              maxLines: 4),
          const SizedBox(height: 16),
          const Eyebrow('BANDEJA'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              ('draft', 'Borrador'),
              ('inbox', 'Entrada'),
              ('follow', 'Seguimiento'),
              ('sent', 'Enviada'),
            ].map((item) {
              final selected = _folder == item.$1;
              return ChoiceChip(
                selected: selected,
                label: Text(item.$2),
                onSelected: (_) => setState(() => _folder = item.$1),
                selectedColor: AppColors.tealMist,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w900,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Prioridad'),
                  items: ['Alta', 'Media', 'Baja']
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _priority = value ?? _priority),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _opportunity,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    'Proveedor',
                    'Transporte',
                    'Demanda',
                    'Finanzas',
                    'Soporte'
                  ]
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _opportunity = value ?? _opportunity),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _save(send: false),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _save(send: true),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Enviar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.canvasDeep,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThreadDetailSheet extends StatelessWidget {
  const ThreadDetailSheet({super.key, required this.thread});

  final PriorityThread thread;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: thread.color.withValues(alpha: 0.22),
              child: Text(thread.avatar,
                  style: TextStyle(
                      color: thread.color, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: SectionTitle(
                    title: thread.sender, subtitle: thread.subject)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Este mensaje puede convertirse en oportunidad comercial. Puedes responder, clasificarlo como proveedor o crear una experiencia relacionada.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72), height: 1.35),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.reply_rounded),
                label: const Text('Responder'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('Crear'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: AppColors.canvasDeep,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TimelinePreview extends StatelessWidget {
  const TimelinePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: PremiumSurface(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            TimelineRow(
                time: '07:30',
                title: 'Salida desde San Salvador',
                icon: Icons.directions_bus_rounded),
            TimelineRow(
                time: '09:00',
                title: 'Llegada y desayuno local',
                icon: Icons.restaurant_rounded),
            TimelineRow(
                time: '10:30',
                title: 'Experiencia principal',
                icon: Icons.beach_access_rounded),
            TimelineRow(
                time: '15:00',
                title: 'Retorno y cierre de ventas',
                icon: Icons.flag_rounded),
          ],
        ),
      ),
    );
  }
}

class TimelineRow extends StatelessWidget {
  const TimelineRow(
      {super.key, required this.time, required this.title, required this.icon});

  final String time;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: AppColors.mint),
            ),
          ),
          IconBadge(icon: icon, color: AppColors.teal, small: true),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class AppGradientScaffold extends StatelessWidget {
  const AppGradientScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.canvas,
      child: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B2630),
                  AppColors.canvas,
                  AppColors.canvasDeep,
                ],
                stops: [0, 0.58, 1],
              ),
            ),
            child: SizedBox.expand(),
          ),
          Positioned(
            top: 0,
            right: -80,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 260,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            top: 86,
            left: -60,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 220,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.045),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TeCaiGoLogo(size: 28),
                SizedBox(height: compact ? 6 : 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 20 : 25,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 13,
                      height: 1.28,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class PremiumSurface extends StatelessWidget {
  const PremiumSurface({super.key, required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.panelSoft.withValues(alpha: 0.94),
            AppColors.panel.withValues(alpha: 0.88),
            AppColors.canvas.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.105)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 40,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.07),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(label.toUpperCase()),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.mint),
            ),
          ),
        ),
      ],
    );
  }
}

class NativeInput extends StatelessWidget {
  const NativeInput({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(label.toUpperCase()),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const Icon(Icons.edit_rounded, size: 18, color: AppColors.mint),
        ],
      ),
    );
  }
}

class SliderField extends StatelessWidget {
  const SliderField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Eyebrow(label.toUpperCase())),
            Text(suffix,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.mint)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge(
      {super.key, required this.icon, required this.color, this.small = false});

  final IconData icon;
  final Color color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 34.0 : 46.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(small ? 12 : 16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(icon, color: color, size: small ? 17 : 22),
    );
  }
}

class MiniKpi extends StatelessWidget {
  const MiniKpi({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56), fontSize: 12),
        ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class TecaigoImage extends StatelessWidget {
  const TecaigoImage({
    super.key,
    required this.src,
    required this.fit,
    this.width,
    this.height,
    this.errorBuilder,
  });

  final String src;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (src.startsWith('assets/')) {
      return Image.asset(
        src,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    }

    return Image.network(
      src,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }
}

class SoftChip extends StatelessWidget {
  const SoftChip(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.tealMist,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.mint),
      ),
    );
  }
}

class GhostStat extends StatelessWidget {
  const GhostStat({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mint, size: 16),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.62),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
      ),
    );
  }
}

class TeCaiGoLogo extends StatelessWidget {
  const TeCaiGoLogo({super.key, required this.size, this.centered = false});

  final double size;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/brand/tecaigo_logo.png',
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    return Align(
      alignment: centered ? Alignment.center : Alignment.centerLeft,
      child: centered ? logo : SizedBox(width: size * 3.92, child: logo),
    );
  }
}

class Interest {
  const Interest(this.id, this.label, this.icon, this.color);

  final String id;
  final String label;
  final IconData icon;
  final Color color;
}

class Opportunity {
  const Opportunity({
    required this.category,
    required this.categoryLabel,
    required this.icon,
    required this.avatar,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.demand,
    required this.cluster,
    required this.status,
    required this.statusColor,
    required this.feedType,
  });

  final String category;
  final String categoryLabel;
  final IconData icon;
  final String avatar;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final String demand;
  final String cluster;
  final String status;
  final Color statusColor;
  final String feedType;
  Color get feedColor =>
      feedType == 'Comercio' ? AppColors.yellow : AppColors.mint;
  IconData get feedIcon =>
      feedType == 'Comercio' ? Icons.storefront_rounded : Icons.route_rounded;
}

class EventPhotoPreset {
  const EventPhotoPreset(this.label, this.icon, this.url);

  final String label;
  final IconData icon;
  final String url;
}

List<String> _splitDateOptions(String text) {
  final dates = text
      .split(RegExp(r'[,;\n]+'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
  return dates.isEmpty ? const ['Fecha pendiente'] : dates;
}

class ClientEvent {
  const ClientEvent({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.badge,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.dateOptions,
    required this.price,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String category;
  final String badge;
  final String imageUrl;
  final String location;
  final String date;
  final List<String> dateOptions;
  final String price;
  final Color color;
}

class ClientReservation {
  const ClientReservation({
    required this.id,
    required this.event,
    required this.guests,
    required this.selectedDate,
    required this.contact,
    required this.note,
    required this.status,
  });

  final String id;
  final ClientEvent event;
  final int guests;
  final String selectedDate;
  final String contact;
  final String note;
  final String status;

  String get totalLabel {
    final unit =
        int.tryParse(event.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return '\$${unit * guests} total';
  }
}

class SalesProduct {
  const SalesProduct({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    required this.color,
  });

  final String kind;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String price;
  final Color color;
}

class TouristBusiness {
  const TouristBusiness({
    required this.name,
    required this.category,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.color,
  });

  final String name;
  final String category;
  final String subtitle;
  final String imageUrl;
  final String rating;
  final Color color;
}

class PromotionDeal {
  const PromotionDeal({
    required this.channel,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.oldPrice,
    required this.price,
    required this.discount,
    required this.icon,
    required this.color,
  });

  final String channel;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String oldPrice;
  final String price;
  final String discount;
  final IconData icon;
  final Color color;
}

enum RequestKind { inbound, outbound }

class ClusterRequest {
  const ClusterRequest({
    required this.id,
    required this.kind,
    required this.from,
    required this.subject,
    required this.body,
    required this.event,
    required this.eventDate,
    required this.imageUrl,
    required this.cupos,
    required this.requestedCupos,
    required this.totalCupos,
    required this.vendidosInternos,
    required this.cuposClusterProtegidos,
    required this.state,
    required this.color,
  });

  final String id;
  final RequestKind kind;
  final String from;
  final String subject;
  final String body;
  final String event;
  final String eventDate;
  final String imageUrl;
  final String cupos;
  final int requestedCupos;
  final int totalCupos;
  final int vendidosInternos;
  final int cuposClusterProtegidos;
  final String state;
  final Color color;

  ClusterRequest copyWith({
    String? state,
    Color? color,
  }) {
    return ClusterRequest(
      id: id,
      kind: kind,
      from: from,
      subject: subject,
      body: body,
      event: event,
      eventDate: eventDate,
      imageUrl: imageUrl,
      cupos: cupos,
      requestedCupos: requestedCupos,
      totalCupos: totalCupos,
      vendidosInternos: vendidosInternos,
      cuposClusterProtegidos: cuposClusterProtegidos,
      state: state ?? this.state,
      color: color ?? this.color,
    );
  }
}

class OccupancyCluster {
  const OccupancyCluster(this.name, this.count, this.icon, this.color);

  final String name;
  final int count;
  final IconData icon;
  final Color color;
}

class OccupancyMember {
  const OccupancyMember({
    required this.initials,
    required this.name,
    required this.cluster,
    required this.count,
    required this.status,
    required this.color,
  });

  final String initials;
  final String name;
  final String cluster;
  final int count;
  final String status;
  final Color color;
}

class OperatorEvent {
  const OperatorEvent({
    required this.title,
    required this.scope,
    required this.date,
    required this.location,
    required this.audience,
    required this.imageUrl,
    required this.status,
    required this.sold,
    required this.capacity,
    required this.protectedCupos,
    required this.tecaigoSold,
    required this.checksReady,
    required this.totalChecks,
    required this.icon,
    required this.color,
  });

  final String title;
  final EventScope scope;
  final String date;
  final String location;
  final String audience;
  final String imageUrl;
  final String status;
  final int sold;
  final int capacity;
  final int protectedCupos;
  final int tecaigoSold;
  final int checksReady;
  final int totalChecks;
  final IconData icon;
  final Color color;
}

enum EventScope { private, public }

String _eventScopeTitle(EventScope scope) {
  return switch (scope) {
    EventScope.private => 'Privados',
    EventScope.public => 'Publicos',
  };
}

String _eventScopeDetail(EventScope scope) {
  return switch (scope) {
    EventScope.private => 'Cluster + TeCaiGO',
    EventScope.public => 'Acepta solicitudes',
  };
}

IconData _eventScopeIcon(EventScope scope) {
  return switch (scope) {
    EventScope.private => Icons.lock_rounded,
    EventScope.public => Icons.public_rounded,
  };
}

Color _eventScopeColor(EventScope scope) {
  return switch (scope) {
    EventScope.private => AppColors.yellow,
    EventScope.public => AppColors.mint,
  };
}

class ValidationItem {
  const ValidationItem({
    required this.title,
    required this.context,
    required this.done,
  });

  final String title;
  final String context;
  final bool done;
}

class PublicSlot {
  const PublicSlot({
    required this.title,
    required this.host,
    required this.free,
    required this.icon,
    required this.color,
  });

  final String title;
  final String host;
  final String free;
  final IconData icon;
  final Color color;
}

class FinanceMovement {
  const FinanceMovement({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color color;
}

class ClusterNode {
  const ClusterNode({
    required this.name,
    required this.signal,
    required this.activeAllies,
    required this.totalAllies,
    required this.icon,
    required this.color,
  });

  final String name;
  final String signal;
  final int activeAllies;
  final int totalAllies;
  final IconData icon;
  final Color color;
}

class DepartureLocation {
  const DepartureLocation({
    required this.id,
    required this.name,
    required this.reference,
    required this.window,
    required this.icon,
  });

  final String id;
  final String name;
  final String reference;
  final String window;
  final IconData icon;
}

class ClusterGovernance {
  const ClusterGovernance({
    required this.name,
    required this.hostId,
    required this.icon,
    required this.color,
    required this.members,
  });

  final String name;
  final String hostId;
  final IconData icon;
  final Color color;
  final List<ClusterMember> members;
}

class ClusterMember {
  const ClusterMember({
    required this.id,
    required this.initials,
    required this.name,
    required this.role,
    required this.capacity,
  });

  final String id;
  final String initials;
  final String name;
  final String role;
  final String capacity;
}

class PriorityThread {
  const PriorityThread({
    required this.avatar,
    required this.sender,
    required this.subject,
    required this.time,
    required this.unread,
    required this.color,
  });

  final String avatar;
  final String sender;
  final String subject;
  final String time;
  final bool unread;
  final Color color;
}

class CorrespondenceRecord {
  const CorrespondenceRecord({
    required this.id,
    required this.avatar,
    required this.contact,
    required this.subject,
    required this.body,
    required this.time,
    required this.folder,
    required this.status,
    required this.priority,
    required this.opportunity,
    required this.color,
  });

  final String id;
  final String avatar;
  final String contact;
  final String subject;
  final String body;
  final String time;
  final String folder;
  final String status;
  final String priority;
  final String opportunity;
  final Color color;

  CorrespondenceRecord copyWith({
    String? id,
    String? subject,
    String? folder,
    String? status,
  }) {
    return CorrespondenceRecord(
      id: id ?? this.id,
      avatar: avatar,
      contact: contact,
      subject: subject ?? this.subject,
      body: body,
      time: time,
      folder: folder ?? this.folder,
      status: status ?? this.status,
      priority: priority,
      opportunity: opportunity,
      color: color,
    );
  }
}

class ModuleItem {
  const ModuleItem(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

const interests = [
  Interest('todos', 'Todos', Icons.auto_awesome_rounded, AppColors.mint),
  Interest('playa', 'Playa', Icons.beach_access_rounded, AppColors.teal),
  Interest('cafe', 'Cafe', Icons.local_cafe_rounded, AppColors.yellow),
  Interest('lago', 'Lago', Icons.water_rounded, Color(0xFF65C7F7)),
  Interest('montana', 'Montana', Icons.terrain_rounded, AppColors.lime),
  Interest('pueblo', 'Pueblo', Icons.storefront_rounded, AppColors.coral),
];

const opportunities = [
  Opportunity(
    category: 'pueblo',
    categoryLabel: 'El Salvador',
    icon: Icons.storefront_rounded,
    avatar: 'AT',
    title: 'Concepcion de Ataco',
    description:
        'Calles empedradas, casas pintorescas, murales y cafe de altura para escapadas culturales.',
    imageUrl: 'assets/turismo/ataco.jpeg',
    tags: ['Ataco', 'Cafe', 'Pueblo'],
    demand: '62 interesados',
    cluster: 'Cluster occidente',
    status: 'Alta demanda',
    statusColor: AppColors.lime,
    feedType: 'Anfitrion',
  ),
  Opportunity(
    category: 'montana',
    categoryLabel: 'Guatemala',
    icon: Icons.account_balance_rounded,
    avatar: 'SF',
    title: 'Castillo de San Felipe',
    description:
        'Ruta historica por Rio Dulce, Izabal, con paseo cultural, fotografia y aliados locales.',
    imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
    tags: ['Guatemala', 'Rio Dulce', 'Castillo'],
    demand: '41 interesados',
    cluster: 'Cluster Guatemala',
    status: 'Listo para publicar',
    statusColor: AppColors.mint,
    feedType: 'Anfitrion',
  ),
  Opportunity(
    category: 'playa',
    categoryLabel: 'El Salvador',
    icon: Icons.beach_access_rounded,
    avatar: 'TU',
    title: 'El Tunco Beach Club',
    description:
        'Comercio turistico frente al mar con day pass, menu costero y capacidad para grupos.',
    imageUrl: 'assets/turismo/el_tunco.jpeg',
    tags: ['Playa', 'Restaurante', 'Surf'],
    demand: '80 capacidad',
    cluster: 'Aliado costa',
    status: 'Acepta reservas',
    statusColor: AppColors.yellow,
    feedType: 'Comercio',
  ),
  Opportunity(
    category: 'montana',
    categoryLabel: 'Guatemala',
    icon: Icons.water_rounded,
    avatar: 'SC',
    title: 'Semuc Champey',
    description:
        'Pozas turquesa, miradores naturales, transporte y hospedaje aliado para aventura regional.',
    imageUrl: 'assets/turismo/semuc_champey.jpeg',
    tags: ['Guatemala', 'Pozas', 'Aventura'],
    demand: '29 interesados',
    cluster: 'Cluster Guatemala',
    status: 'Busca anfitrion',
    statusColor: Color(0xFF65C7F7),
    feedType: 'Anfitrion',
  ),
  Opportunity(
    category: 'lago',
    categoryLabel: 'El Salvador',
    icon: Icons.hotel_rounded,
    avatar: 'CA',
    title: 'Hostal Lago Coatepeque',
    description:
        'Hospedaje aliado con vista al lago, desayuno y acceso a muelle para grupos turisticos.',
    imageUrl: 'assets/turismo/agua_turquesa.jpeg',
    tags: ['Hostal', 'Lago', 'Habitaciones'],
    demand: '6 habitaciones',
    cluster: 'Aliado Honduras',
    status: 'Disponible',
    statusColor: AppColors.yellow,
    feedType: 'Comercio',
  ),
  Opportunity(
    category: 'montana',
    categoryLabel: 'El Salvador',
    icon: Icons.waterfall_chart_rounded,
    avatar: 'ML',
    title: 'Salto de Malacatiupan',
    description:
        'Cascada termal, experiencia de aventura, guia local y puntos de descanso en ruta.',
    imageUrl: 'assets/turismo/salto_malacatiupan.jpeg',
    tags: ['Termal', 'Cascada', 'Aventura'],
    demand: '37 interesados',
    cluster: 'Cluster Nicaragua',
    status: 'Requiere aliados',
    statusColor: AppColors.yellow,
    feedType: 'Anfitrion',
  ),
  Opportunity(
    category: 'montana',
    categoryLabel: 'Centroamerica',
    icon: Icons.tour_rounded,
    avatar: 'CA',
    title: 'Centroamerica Increible',
    description:
        'Agencia regional para circuitos por pueblos, playas, lagos y destinos naturales.',
    imageUrl: 'assets/turismo/centroamerica_places.jpeg',
    tags: ['Agencia', 'Regional', 'Circuito'],
    demand: '35 cupos',
    cluster: 'Aliado Nicaragua',
    status: 'Publico',
    statusColor: AppColors.yellow,
    feedType: 'Comercio',
  ),
];

const eventPhotoPresets = [
  EventPhotoPreset(
    'Ataco',
    Icons.storefront_rounded,
    'assets/turismo/ataco.jpeg',
  ),
  EventPhotoPreset(
    'San Felipe',
    Icons.account_balance_rounded,
    'assets/turismo/castillo_san_felipe.jpeg',
  ),
  EventPhotoPreset(
    'El Tunco',
    Icons.beach_access_rounded,
    'assets/turismo/el_tunco.jpeg',
  ),
  EventPhotoPreset(
    'Semuc',
    Icons.water_rounded,
    'assets/turismo/semuc_champey.jpeg',
  ),
];

const clientEvents = [
  ClientEvent(
    title: 'Concepcion de Ataco y Ruta del Cafe',
    subtitle:
        'Calles empedradas, murales, cafe de altura y miradores de occidente.',
    category: 'El Salvador',
    badge: 'Alta demanda',
    imageUrl: 'assets/turismo/ataco.jpeg',
    location: 'Ataco - Ruta de las Flores',
    date: 'Sab 25 mayo',
    dateOptions: ['Sab 25 mayo', 'Dom 26 mayo', 'Sab 1 junio'],
    price: '\$45',
    color: AppColors.lime,
  ),
  ClientEvent(
    title: 'Castillo de San Felipe y Rio Dulce',
    subtitle:
        'Viaje cultural por Izabal con historia, fotografia, lancha y comida local.',
    category: 'Guatemala',
    badge: 'Cultura',
    imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
    location: 'Rio Dulce, Izabal',
    date: 'Dom 26 mayo',
    dateOptions: ['Dom 26 mayo', 'Vie 31 mayo', 'Dom 9 junio'],
    price: '\$119',
    color: AppColors.yellow,
  ),
  ClientEvent(
    title: 'El Tunco Beach Weekend',
    subtitle:
        'Surf, atardecer, gastronomia costera, musica y transporte para escapada de playa.',
    category: 'El Salvador',
    badge: 'Playa',
    imageUrl: 'assets/turismo/el_tunco.jpeg',
    location: 'El Tunco, La Libertad',
    date: 'Dom 2 junio',
    dateOptions: ['Dom 2 junio', 'Vie 7 junio', 'Sab 15 junio'],
    price: '\$189',
    color: Color(0xFF65C7F7),
  ),
  ClientEvent(
    title: 'Semuc Champey Aventura',
    subtitle:
        'Pozas naturales, miradores, cuevas, guia local y hospedaje para aventura regional.',
    category: 'Guatemala',
    badge: 'Naturaleza',
    imageUrl: 'assets/turismo/semuc_champey.jpeg',
    location: 'Semuc Champey, Alta Verapaz',
    date: 'Sab 8 junio',
    dateOptions: ['Sab 8 junio', 'Dom 16 junio', 'Sab 22 junio'],
    price: '\$99',
    color: AppColors.mint,
  ),
];

const ticketProducts = [
  SalesProduct(
    kind: 'Concierto',
    title: 'El Tunco Sunset Pass',
    subtitle:
        'Boleto digital para sunset session, acceso QR y zona preferente.',
    imageUrl: 'assets/turismo/el_tunco.jpeg',
    price: 'Desde \$65',
    color: AppColors.coral,
  ),
  SalesProduct(
    kind: 'Museo',
    title: 'Castillo San Felipe',
    subtitle: 'Entrada programada, guia cultural y confirmacion inmediata.',
    imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
    price: 'Desde \$16',
    color: AppColors.yellow,
  ),
  SalesProduct(
    kind: 'Boleteria',
    title: 'Pase Cascada Termal',
    subtitle: 'Entrada a Malacatiupan, horario reservado y control QR.',
    imageUrl: 'assets/turismo/salto_malacatiupan.jpeg',
    price: 'Desde \$18',
    color: AppColors.mint,
  ),
  SalesProduct(
    kind: 'Concierto',
    title: 'Ataco Noche Cultural',
    subtitle: 'Entrada a show local, mesa reservada y traslado opcional.',
    imageUrl: 'assets/turismo/ataco.jpeg',
    price: 'Desde \$42',
    color: Color(0xFF65C7F7),
  ),
  SalesProduct(
    kind: 'Museo',
    title: 'Ruta historia + cafe',
    subtitle: 'Entrada cultural, degustacion y cupo confirmado.',
    imageUrl: 'assets/turismo/centroamerica_places.jpeg',
    price: 'Desde \$24',
    color: AppColors.lime,
  ),
];

const agencyProducts = [
  SalesProduct(
    kind: 'Agencia',
    title: 'Ataco y Ruta del Cafe',
    subtitle: 'Pueblo, murales, cafe, transporte y aliados locales.',
    imageUrl: 'assets/turismo/ataco.jpeg',
    price: 'Cotizar',
    color: AppColors.mint,
  ),
  SalesProduct(
    kind: 'Agencia',
    title: 'El Tunco Beach completo',
    subtitle: 'Hotel, playa, surf, gastronomia y asistencia de agencia.',
    imageUrl: 'assets/turismo/el_tunco.jpeg',
    price: 'Desde \$219',
    color: Color(0xFF65C7F7),
  ),
  SalesProduct(
    kind: 'Agencia',
    title: 'Semuc Champey aventura',
    subtitle: 'Transporte, hospedaje, guia, pozas y cuevas naturales.',
    imageUrl: 'assets/turismo/semuc_champey.jpeg',
    price: 'Desde \$1,280',
    color: AppColors.yellow,
  ),
  SalesProduct(
    kind: 'Agencia',
    title: 'Rio Dulce e Izabal',
    subtitle: 'Castillo, lancha, hotel, transporte y agenda familiar.',
    imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
    price: 'Desde \$899',
    color: AppColors.coral,
  ),
  SalesProduct(
    kind: 'Agencia',
    title: 'Malacatiupan termal',
    subtitle: 'Cascada termal, guia local, transporte y descanso para grupos.',
    imageUrl: 'assets/turismo/salto_malacatiupan.jpeg',
    price: 'Desde \$149',
    color: AppColors.lime,
  ),
];

const touristBusinesses = [
  TouristBusiness(
    name: 'TeCaiGO Tickets',
    category: 'Boleteria',
    subtitle:
        'Entradas digitales para Ataco, Malacatiupan y San Felipe con QR.',
    imageUrl: 'assets/turismo/ataco.jpeg',
    rating: '4.9',
    color: AppColors.yellow,
  ),
  TouristBusiness(
    name: 'Aereo Centroamerica',
    category: 'Vuelos',
    subtitle:
        'Boletos aereos regionales, cambios flexibles y soporte por WhatsApp.',
    imageUrl: 'assets/turismo/centroamerica_places.jpeg',
    rating: '4.8',
    color: Color(0xFF65C7F7),
  ),
  TouristBusiness(
    name: 'Viajes Ruta Cafe',
    category: 'Agencia',
    subtitle:
        'Paquetes regionales a Ataco, El Tunco, Izabal y Semuc para grupos.',
    imageUrl: 'assets/turismo/el_tunco.jpeg',
    rating: '4.8',
    color: AppColors.mint,
  ),
  TouristBusiness(
    name: 'Weekend Centroamerica',
    category: 'Paquetes',
    subtitle:
        'Combos de vuelo, hotel, transporte y actividades para escapadas.',
    imageUrl: 'assets/turismo/semuc_champey.jpeg',
    rating: '4.9',
    color: AppColors.mint,
  ),
  TouristBusiness(
    name: 'TeCaiGO Concerts',
    category: 'Conciertos',
    subtitle:
        'Entradas, shuttle, paquetes con hotel y control digital de acceso.',
    imageUrl: 'assets/turismo/el_tunco.jpeg',
    rating: '4.7',
    color: AppColors.coral,
  ),
  TouristBusiness(
    name: 'Gastro Ataco',
    category: 'Restaurante',
    subtitle: 'Almuerzos tipicos, cafe de altura y paradas de ruta en Ataco.',
    imageUrl: 'assets/turismo/ataco.jpeg',
    rating: '4.8',
    color: AppColors.yellow,
  ),
  TouristBusiness(
    name: 'Hostal Rio Dulce',
    category: 'Hostal',
    subtitle: 'Hospedaje aliado para tours culturales en Izabal y San Felipe.',
    imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
    rating: '4.7',
    color: Color(0xFF65C7F7),
  ),
  TouristBusiness(
    name: 'Shuttle Centroamerica',
    category: 'Transporte',
    subtitle: 'Traslados compartidos hacia Ataco, El Tunco, Izabal y Semuc.',
    imageUrl: 'assets/turismo/centroamerica_places.jpeg',
    rating: '4.9',
    color: AppColors.mint,
  ),
  TouristBusiness(
    name: 'Semuc Tours',
    category: 'Tour',
    subtitle:
        'Pozas turquesa, cuevas y circuitos fotograficos en Alta Verapaz.',
    imageUrl: 'assets/turismo/semuc_champey.jpeg',
    rating: '4.8',
    color: AppColors.lime,
  ),
];

const promotionDeals = [
  PromotionDeal(
    channel: 'Eventos',
    title: 'Ataco Cafe 2x1',
    subtitle:
        'Salida de tour operador con segundo cupo al 50% para compras hoy.',
    imageUrl: 'assets/turismo/ataco.jpeg',
    oldPrice: 'Antes \$49',
    price: 'Desde \$39',
    discount: '-20%',
    icon: Icons.route_rounded,
    color: AppColors.mint,
  ),
  PromotionDeal(
    channel: 'Boleteria',
    title: 'Castillo San Felipe',
    subtitle: 'Entrada digital con guia incluido y horario preferente.',
    imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
    oldPrice: 'Antes \$16',
    price: 'Desde \$12',
    discount: '-25%',
    icon: Icons.local_activity_rounded,
    color: AppColors.yellow,
  ),
  PromotionDeal(
    channel: 'Agencias',
    title: 'El Tunco Beach completo',
    subtitle: 'Paquete de agencia con hotel, traslado y surf en promocion.',
    imageUrl: 'assets/turismo/el_tunco.jpeg',
    oldPrice: 'Antes \$235',
    price: 'Desde \$199',
    discount: '-15%',
    icon: Icons.flight_takeoff_rounded,
    color: Color(0xFF65C7F7),
  ),
  PromotionDeal(
    channel: 'Aliados',
    title: 'Gastro Ataco grupo',
    subtitle:
        'Menu turistico con bebida incluida para grupos en Ruta del Cafe.',
    imageUrl: 'assets/turismo/ataco.jpeg',
    oldPrice: 'Antes \$14',
    price: 'Desde \$11',
    discount: '-18%',
    icon: Icons.restaurant_rounded,
    color: AppColors.lime,
  ),
  PromotionDeal(
    channel: 'Conciertos',
    title: 'El Tunco Sunset VIP',
    subtitle: 'Entrada, fast line y shuttle nocturno con cupos limitados.',
    imageUrl: 'assets/turismo/el_tunco.jpeg',
    oldPrice: 'Antes \$62',
    price: 'Desde \$55',
    discount: '-10%',
    icon: Icons.music_note_rounded,
    color: AppColors.coral,
  ),
  PromotionDeal(
    channel: 'Agencias',
    title: 'Semuc Champey guiado',
    subtitle: 'Transporte, hotel y tour natural con tarifa promocional.',
    imageUrl: 'assets/turismo/semuc_champey.jpeg',
    oldPrice: 'Antes \$1,280',
    price: 'Desde \$1,180',
    discount: '-8%',
    icon: Icons.card_travel_rounded,
    color: AppColors.yellow,
  ),
];

const requests = [
  ClusterRequest(
    id: 'req-1',
    kind: RequestKind.inbound,
    from: 'Gastro Occidente Tours',
    subject: 'Solicita cupos para vender',
    body:
        'Quiere tomar cupos de tu evento publico para venderlos bajo la comision acordada.',
    event: 'Concepcion de Ataco y Ruta del Cafe',
    eventDate: 'Sab 25 mayo - salida 6:00 a.m.',
    imageUrl: 'assets/turismo/ataco.jpeg',
    cupos: '5 cupos',
    requestedCupos: 5,
    totalCupos: 50,
    vendidosInternos: 32,
    cuposClusterProtegidos: 10,
    state: 'Pendiente',
    color: AppColors.yellow,
  ),
  ClusterRequest(
    id: 'req-2',
    kind: RequestKind.outbound,
    from: 'TeCaiGO Operador',
    subject: 'Solicitud de cupos externos',
    body:
        'Se pidieron cupos para vender Castillo de San Felipe desde cartera de turistas propia.',
    event: 'Castillo de San Felipe y Rio Dulce',
    eventDate: 'Dom 26 mayo - cultura y hotel',
    imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
    cupos: '12 cupos',
    requestedCupos: 12,
    totalCupos: 38,
    vendidosInternos: 21,
    cuposClusterProtegidos: 8,
    state: 'Pendiente',
    color: AppColors.yellow,
  ),
  ClusterRequest(
    id: 'req-3',
    kind: RequestKind.inbound,
    from: 'Semuc Tours',
    subject: 'Solicita inventario publico',
    body:
        'Quiere cupos para vender esta salida a su cartera de turistas regionales.',
    event: 'Semuc Champey Aventura',
    eventDate: 'Dom 2 junio - ruta colonial',
    imageUrl: 'assets/turismo/semuc_champey.jpeg',
    cupos: '8 cupos',
    requestedCupos: 8,
    totalCupos: 42,
    vendidosInternos: 14,
    cuposClusterProtegidos: 12,
    state: 'Pendiente',
    color: AppColors.mint,
  ),
];

List<OccupancyCluster> _occupancyClusters(OperatorEvent event,
    {int? internalSold}) {
  final externalAuthorized =
      approvedExternalCupos[_eventInventoryKey(event.title, event.date)] ?? 0;
  return [
    OccupancyCluster('Internos (integrantes del cluster)',
        internalSold ?? event.sold, Icons.groups_2_outlined, AppColors.mint),
    if (externalAuthorized > 0)
      OccupancyCluster(_externalRequesterName(event), externalAuthorized,
          Icons.handshake_outlined, Color(0xFF65C7F7)),
    OccupancyCluster('TeCaiGO', event.tecaigoSold, Icons.storefront_outlined,
        AppColors.coral),
  ];
}

String _externalRequesterName(OperatorEvent event) {
  for (final request in requests) {
    if (request.event == event.title && request.eventDate == event.date) {
      return 'Externos - ${request.from}';
    }
  }
  return 'Externos';
}

List<OccupancyMember> _occupancyMembers(OperatorEvent event) {
  if (event.title.contains('Ataco')) {
    return const [
      OccupancyMember(
          initials: 'MG',
          name: 'Ataco Cafe Tours',
          cluster: 'Internos',
          count: 4,
          status: 'Pagado',
          color: AppColors.mint),
      OccupancyMember(
          initials: 'VP',
          name: 'Viajes Pacifico',
          cluster: 'Externos',
          count: 8,
          status: 'Reserva',
          color: Color(0xFF65C7F7)),
      OccupancyMember(
          initials: 'JR',
          name: 'TeCaiGO',
          cluster: 'TeCaiGO',
          count: 2,
          status: 'Pagado',
          color: AppColors.lime),
      OccupancyMember(
          initials: 'GO',
          name: 'Gastro Ataco',
          cluster: 'Aliado operador',
          count: 6,
          status: 'Cupo',
          color: AppColors.yellow),
    ];
  }
  if (event.title.contains('San Felipe')) {
    return const [
      OccupancyMember(
          initials: 'CT',
          name: 'Rio Dulce Tours',
          cluster: 'Internos',
          count: 10,
          status: 'Reserva',
          color: AppColors.yellow),
      OccupancyMember(
          initials: 'VP',
          name: 'Viajes Pacifico',
          cluster: 'Externos',
          count: 6,
          status: 'Pagado',
          color: AppColors.mint),
      OccupancyMember(
          initials: 'AL',
          name: 'TeCaiGO',
          cluster: 'TeCaiGO',
          count: 3,
          status: 'Pagado',
          color: Color(0xFF65C7F7)),
    ];
  }
  return const [
    OccupancyMember(
        initials: 'GR',
        name: 'Semuc Tours',
        cluster: 'Externos',
        count: 5,
        status: 'Reserva',
        color: AppColors.lime),
    OccupancyMember(
        initials: 'CM',
        name: 'Semuc Cluster',
        cluster: 'Internos',
        count: 2,
        status: 'Pagado',
        color: AppColors.yellow),
    OccupancyMember(
        initials: 'SC',
        name: 'Shuttle Centroamerica',
        cluster: 'Aliado operador',
        count: 4,
        status: 'Cupo',
        color: AppColors.mint),
  ];
}

const operatorEvents = [
  OperatorEvent(
    title: 'Concepcion de Ataco y Ruta del Cafe',
    scope: EventScope.public,
    date: 'Sab 25 mayo - salida 6:00 a.m.',
    location: 'Ataco - Apaneca - Ruta de las Flores',
    audience: 'Cafe, pueblo, parejas y fotografia',
    imageUrl: 'assets/turismo/ataco.jpeg',
    status: 'Preventa',
    sold: 32,
    capacity: 50,
    protectedCupos: 10,
    tecaigoSold: 3,
    checksReady: 4,
    totalChecks: 6,
    icon: Icons.storefront_rounded,
    color: AppColors.mint,
  ),
  OperatorEvent(
    title: 'Castillo de San Felipe y Rio Dulce',
    scope: EventScope.private,
    date: 'Dom 26 mayo - cultura y hotel',
    location: 'Rio Dulce, Izabal',
    audience: 'Cultura, familias y fotografia',
    imageUrl: 'assets/turismo/castillo_san_felipe.jpeg',
    status: 'Validando',
    sold: 21,
    capacity: 38,
    protectedCupos: 8,
    tecaigoSold: 2,
    checksReady: 5,
    totalChecks: 6,
    icon: Icons.account_balance_rounded,
    color: AppColors.yellow,
  ),
  OperatorEvent(
    title: 'Semuc Champey Aventura',
    scope: EventScope.public,
    date: 'Dom 2 junio - ruta colonial',
    location: 'Alta Verapaz, Guatemala',
    audience: 'Aventura, pozas y grupos privados',
    imageUrl: 'assets/turismo/semuc_champey.jpeg',
    status: 'Aliados',
    sold: 14,
    capacity: 42,
    protectedCupos: 12,
    tecaigoSold: 4,
    checksReady: 3,
    totalChecks: 6,
    icon: Icons.water_rounded,
    color: Color(0xFF65C7F7),
  ),
];

const validationItems = [
  ValidationItem(
    title: 'Transporte confirmado',
    context: 'Ataco - falta contacto final del proveedor',
    done: false,
  ),
  ValidationItem(
    title: 'Menu y capacidad',
    context: 'Gastro Occidente - 50 cupos aprobados',
    done: true,
  ),
  ValidationItem(
    title: 'Seguro / contacto emergencia',
    context: 'Rio Dulce - pendiente documento',
    done: false,
  ),
];

const publicSlots = [
  PublicSlot(
    title: 'Ataco Cafe Express',
    host: 'TeCaiGO Tours - El Salvador',
    free: '9 cupos',
    icon: Icons.volcano_rounded,
    color: AppColors.lime,
  ),
  PublicSlot(
    title: 'Castillo San Felipe',
    host: 'Hostal Rio Dulce',
    free: '18 cupos',
    icon: Icons.account_balance_rounded,
    color: AppColors.yellow,
  ),
  PublicSlot(
    title: 'Shuttle Centroamerica',
    host: 'Shuttle Centroamerica',
    free: '3 vans',
    icon: Icons.airport_shuttle_rounded,
    color: AppColors.mint,
  ),
];

const financeMovements = [
  FinanceMovement(
    title: 'Preventa Ataco',
    subtitle: '32 cupos confirmados',
    amount: '+\$1,248',
    icon: Icons.trending_up_rounded,
    color: AppColors.lime,
  ),
  FinanceMovement(
    title: 'Comision operador externo',
    subtitle: 'Castillo San Felipe - 9 cupos',
    amount: '+\$315',
    icon: Icons.handshake_outlined,
    color: AppColors.mint,
  ),
  FinanceMovement(
    title: 'Liquidacion pendiente',
    subtitle: 'Transporte y proveedor local',
    amount: '-\$410',
    icon: Icons.schedule_rounded,
    color: AppColors.yellow,
  ),
];

const clusters = [
  ClusterNode(
    name: 'El Salvador',
    signal: 'Ataco, cafe y aliados gastronomicos listos',
    activeAllies: 12,
    totalAllies: 15,
    icon: Icons.volcano_rounded,
    color: AppColors.yellow,
  ),
  ClusterNode(
    name: 'Guatemala',
    signal: 'Rio Dulce y Semuc con hoteleria y transporte en venta',
    activeAllies: 8,
    totalAllies: 10,
    icon: Icons.beach_access_rounded,
    color: AppColors.mint,
  ),
  ClusterNode(
    name: 'Costa',
    signal: 'El Tunco y Malacatiupan disponibles para paquetes privados',
    activeAllies: 6,
    totalAllies: 9,
    icon: Icons.camera_alt_rounded,
    color: Color(0xFF65C7F7),
  ),
];

const seedDepartureLocations = [
  DepartureLocation(
    id: 'metrocentro-san-salvador',
    name: 'Metrocentro San Salvador',
    reference: 'Entrada principal frente a 7a etapa',
    window: '5:30 a.m. - 6:00 a.m.',
    icon: Icons.location_on_outlined,
  ),
  DepartureLocation(
    id: 'santa-ana-catedral',
    name: 'Catedral de Santa Ana',
    reference: 'Costado del parque Libertad',
    window: '6:20 a.m. - 6:40 a.m.',
    icon: Icons.account_balance_outlined,
  ),
  DepartureLocation(
    id: 'plaza-mundo',
    name: 'Plaza Mundo Soyapango',
    reference: 'Zona de buses turisticos',
    window: '5:00 a.m. - 5:20 a.m.',
    icon: Icons.directions_bus_outlined,
  ),
];

const tecaigoCluster = ClusterGovernance(
  name: 'Cluster TeCaiGO',
  hostId: 'santa-ana-express',
  icon: Icons.hub_outlined,
  color: AppColors.mint,
  members: [
    ClusterMember(
      id: 'santa-ana-express',
      initials: 'SA',
      name: 'Ataco Cafe Express',
      role: 'Tour operador',
      capacity: '28 cupos',
    ),
    ClusterMember(
      id: 'gastro-occidente',
      initials: 'GO',
      name: 'Gastro Occidente Tours',
      role: 'Tour operador',
      capacity: '35 cupos',
    ),
    ClusterMember(
      id: 'shuttle-centroamerica',
      initials: 'SC',
      name: 'Shuttle Centroamerica',
      role: 'Tour operador',
      capacity: '4 vans',
    ),
    ClusterMember(
      id: 'ruta-flores-cafe',
      initials: 'RF',
      name: 'Ruta Flores Tours',
      role: 'Tour operador',
      capacity: '32 cupos',
    ),
  ],
);

const externalTourOperators = [
  ClusterMember(
    id: 'rio-dulce-tours',
    initials: 'RD',
    name: 'Rio Dulce Tours',
    role: 'Tour operador',
    capacity: '40 cupos',
  ),
  ClusterMember(
    id: 'semuc-tours',
    initials: 'ST',
    name: 'Semuc Tours',
    role: 'Tour operador',
    capacity: '30 cupos',
  ),
  ClusterMember(
    id: 'el-tunco-surf',
    initials: 'ET',
    name: 'El Tunco Surf',
    role: 'Tour operador',
    capacity: '24 cupos',
  ),
  ClusterMember(
    id: 'moncagua-adventure',
    initials: 'MA',
    name: 'Moncagua Adventure',
    role: 'Tour operador',
    capacity: '26 cupos',
  ),
  ClusterMember(
    id: 'malacatiupan-tours',
    initials: 'MT',
    name: 'Malacatiupan Tours',
    role: 'Tour operador',
    capacity: '22 cupos',
  ),
  ClusterMember(
    id: 'guatemala-explorer',
    initials: 'GX',
    name: 'Guatemala Explorer',
    role: 'Tour operador',
    capacity: '45 cupos',
  ),
];

const clusterGovernance = [
  ClusterGovernance(
    name: 'Cluster Occidente',
    hostId: 'santa-ana-express',
    icon: Icons.volcano_rounded,
    color: AppColors.mint,
    members: [
      ClusterMember(
        id: 'santa-ana-express',
        initials: 'SA',
        name: 'Ataco Cafe Express',
        role: 'Anfitrion turistico',
        capacity: '28 cupos',
      ),
      ClusterMember(
        id: 'gastro-occidente',
        initials: 'GO',
        name: 'Gastro Occidente',
        role: 'Comercio turistico',
        capacity: '70 almuerzos',
      ),
      ClusterMember(
        id: 'shuttle-centroamerica',
        initials: 'SC',
        name: 'Shuttle Centroamerica',
        role: 'Transporte',
        capacity: '4 vans',
      ),
      ClusterMember(
        id: 'ruta-flores-cafe',
        initials: 'RF',
        name: 'Ruta Flores Cafe',
        role: 'Aliado local',
        capacity: '32 visitas',
      ),
    ],
  ),
  ClusterGovernance(
    name: 'Cluster Guatemala',
    hostId: 'rio-dulce-tours',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF65C7F7),
    members: [
      ClusterMember(
        id: 'rio-dulce-tours',
        initials: 'RD',
        name: 'Rio Dulce Tours',
        role: 'Anfitrion turistico',
        capacity: '40 cupos',
      ),
      ClusterMember(
        id: 'hostal-rio-dulce',
        initials: 'HR',
        name: 'Hostal Rio Dulce',
        role: 'Hospedaje',
        capacity: '18 habitaciones',
      ),
      ClusterMember(
        id: 'semuc-hostal',
        initials: 'SH',
        name: 'Semuc Hostal',
        role: 'Aliado natural',
        capacity: '24 cupos',
      ),
    ],
  ),
  ClusterGovernance(
    name: 'Cluster Costa',
    hostId: 'el-tunco-surf',
    icon: Icons.camera_alt_rounded,
    color: AppColors.lime,
    members: [
      ClusterMember(
        id: 'el-tunco-surf',
        initials: 'ET',
        name: 'El Tunco Surf',
        role: 'Anfitrion turistico',
        capacity: '30 cupos',
      ),
      ClusterMember(
        id: 'malacatiupan-tours',
        initials: 'MT',
        name: 'Malacatiupan Tours',
        role: 'Experiencia termal',
        capacity: '20 bicicletas',
      ),
      ClusterMember(
        id: 'tunco-cafe',
        initials: 'TC',
        name: 'Tunco Cafe',
        role: 'Comercio turistico',
        capacity: '45 desayunos',
      ),
    ],
  ),
];

const priorityThreads = [
  PriorityThread(
    avatar: 'GO',
    sender: 'Gastro Occidente',
    subject: 'Menus disponibles para Ataco',
    time: '10:12',
    unread: true,
    color: AppColors.mint,
  ),
  PriorityThread(
    avatar: 'SC',
    sender: 'Shuttle Centroamerica',
    subject: '8 unidades disponibles para Rio Dulce y Semuc',
    time: '09:40',
    unread: true,
    color: AppColors.lime,
  ),
  PriorityThread(
    avatar: 'UN',
    sender: 'Universidad Turismo',
    subject: '28 estudiantes disponibles para practicas',
    time: '09:05',
    unread: false,
    color: Color(0xFF65C7F7),
  ),
];

final operatorResponseThreads = <PriorityThread>[];

final approvedExternalCupos = <String, int>{};

String _eventInventoryKey(String event, String date) => '$event::$date';

const modules = [
  ModuleItem('Validaciones', 'Checklist antes de publicar',
      Icons.verified_outlined, AppColors.lime),
  ModuleItem('Mis eventos', 'Ventas, cupos y calendario',
      Icons.event_available_outlined, AppColors.mint),
  ModuleItem('Eventos publicos', 'Oferta por cluster', Icons.public_rounded,
      Color(0xFF65C7F7)),
  ModuleItem('Finanzas', 'Comisiones y liquidaciones', Icons.payments_outlined,
      AppColors.yellow),
  ModuleItem(
      'Clusters', 'Aliados y rutas vivas', Icons.hub_outlined, AppColors.teal),
  ModuleItem('Admin', 'Usuarios y reglas', Icons.admin_panel_settings_outlined,
      AppColors.coral),
];
