// frontend/lib/routes/app_router.dart
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/home_screen.dart';
import '../screens/auth/student_login_screen.dart';
import '../screens/auth/student_register_screen.dart';
import '../screens/auth/warden_login_screen.dart';
import '../screens/auth/warden_register_screen.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/attendance_face_screen.dart';
import '../screens/student/complaints_screen.dart';
import '../screens/student/notices_screen.dart';
import '../screens/student/mess_menu_screen.dart';
import '../screens/student/room_info_screen.dart';
import '../screens/student/profile_screen.dart';
import '../screens/warden/warden_dashboard_screen.dart';
import '../screens/warden/all_attendance_screen.dart';
import '../screens/warden/manage_complaints_screen.dart';
import '../screens/warden/manage_notices_screen.dart';
import '../screens/warden/manage_mess_menu_screen.dart';
import '../screens/warden/manage_rooms_screen.dart';
import '../screens/warden/student_search_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/student-login',
        builder: (context, state) => const StudentLoginScreen(),
      ),
      GoRoute(
        path: '/student-register',
        builder: (context, state) => const StudentRegisterScreen(),
      ),
      GoRoute(
        path: '/warden-login',
        builder: (context, state) => const WardenLoginScreen(),
      ),
      GoRoute(
        path: '/warden-register',
        builder: (context, state) => const WardenRegisterScreen(),
      ),
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: '/student-attendance',
        builder: (context, state) => const AttendanceFaceScreen(),
      ),
      GoRoute(
        path: '/student-complaints',
        builder: (context, state) => const ComplaintsScreen(),
      ),
      GoRoute(
        path: '/student-notices',
        builder: (context, state) => const NoticesScreen(),
      ),
      GoRoute(
        path: '/student-mess-menu',
        builder: (context, state) => const MessMenuScreen(),
      ),
      GoRoute(
        path: '/student-room-info',
        builder: (context, state) => const RoomInfoScreen(),
      ),
      GoRoute(
        path: '/student-profile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
      GoRoute(
        path: '/warden-dashboard',
        builder: (context, state) => const WardenDashboardScreen(),
      ),
      GoRoute(
        path: '/warden-attendance',
        builder: (context, state) => const AllAttendanceScreen(),
      ),
      GoRoute(
        path: '/warden-complaints',
        builder: (context, state) => const ManageComplaintsScreen(),
      ),
      GoRoute(
        path: '/warden-notices',
        builder: (context, state) => const ManageNoticesScreen(),
      ),
      GoRoute(
        path: '/warden-mess-menu',
        builder: (context, state) => const ManageMessMenuScreen(),
      ),
      GoRoute(
        path: '/warden-rooms',
        builder: (context, state) => const ManageRoomsScreen(),
      ),
      GoRoute(
        path: '/warden-search',
        builder: (context, state) => const StudentSearchScreen(),
      ),
    ],
  );
}
