// import 'package:collapsible_sidebar/collapsible_sidebar.dart';
// import 'package:flutter/material.dart';
// import 'package:hrm_dump_flutter/screens/dashbord/attendances_form.dart';
// import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
//
// class NewDashBoardScreen extends StatefulWidget {
//   @override
//   _NewDashBoardScreenState createState() => _NewDashBoardScreenState();
// }
//
// class _NewDashBoardScreenState extends State<NewDashBoardScreen> {
//   late List<CollapsibleItem> _items;
//   late String _headline;
//   AssetImage _avatarImg = AssetImage('assets/man.png');
//   bool _isSidebarVisible = false;
//   bool _isNavigating = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _items = _generateItems;
//     final selectedItem = _items.firstWhere(
//       (item) => item.isSelected,
//       orElse: () => _items[0],
//     );
//     _headline = selectedItem.text;
//   }
//
//   void _toggleSidebar() {
//     setState(() {
//       _isSidebarVisible = !_isSidebarVisible;
//     });
//   }
//
//   List<CollapsibleItem> get _generateItems {
//     return [
//       CollapsibleItem(
//         text: 'AttendanceForm',
//         icon: Icons.search,
//         onPressed: () {
//           if (_isNavigating) return; // Prevent multiple rapid taps
//
//           setState(() {
//             _isNavigating = true;
//             _headline = 'AttendanceForm';
//             _isSidebarVisible = false;
//           });
//
//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             await Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => AttendanceFormPage()),
//             );
//
//             // After return from page, reset flag & rebuild items
//             setState(() {
//               _isNavigating = false;
//               _items = _generateItems; // <--- Refresh sidebar items
//             });
//           });
//         },
//         isSelected: false,
//       ),
//       CollapsibleItem(
//         text: 'Attendance Record',
//         icon: Icons.search,
//         onPressed: () {
//           if (_isNavigating) return; // Prevent multiple rapid taps
//
//           setState(() {
//             _isNavigating = true;
//             _headline = 'Attendance Record';
//             _isSidebarVisible = false;
//           });
//
//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             await Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => AttendanceFormPage()),
//             );
//
//             // After return from page, reset flag & rebuild items
//             setState(() {
//               _isNavigating = false;
//               _items = _generateItems; // <--- Refresh sidebar items
//             });
//           });
//         },
//         isSelected: false,
//       ),
//       CollapsibleItem(
//         text: 'Leave',
//         icon: Icons.search,
//         onPressed: () {
//           if (_isNavigating) return; // Prevent multiple rapid taps
//
//           setState(() {
//             _isNavigating = true;
//             _headline = 'Leave';
//             _isSidebarVisible = false;
//           });
//
//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             await Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => AttendanceFormPage()),
//             );
//
//             // After return from page, reset flag & rebuild items
//             setState(() {
//               _isNavigating = false;
//               _items = _generateItems; // <--- Refresh sidebar items
//             });
//           });
//         },
//         isSelected: false,
//       ),
//       CollapsibleItem(
//         text: 'Leave Record',
//         icon: Icons.search,
//         onPressed: () {
//           if (_isNavigating) return; // Prevent multiple rapid taps
//
//           setState(() {
//             _isNavigating = true;
//             _headline = 'Leave Record';
//             _isSidebarVisible = false;
//           });
//
//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             await Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => AttendanceFormPage()),
//             );
//             // After return from page, reset flag & rebuild items
//             setState(() {
//               _isNavigating = false;
//               _items = _generateItems; // <--- Refresh sidebar items
//             });
//           });
//         },
//         isSelected: false,
//         onHold:
//             () => ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text("Leave Record"))),
//       ),
//       CollapsibleItem(
//         text: 'Jobs',
//         icon: Icons.account_balance,
//         onPressed: () {
//           if (_isNavigating) return;
//           setState(() {
//             _headline = 'Jobs';
//             _isSidebarVisible = false;
//           });
//         },
//         onHold:
//             () => ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text("Jobs"))),
//
//         isSelected: false,
//         subItems: [
//           CollapsibleItem(
//             text: 'Job Openings',
//             icon: Icons.search,
//             onPressed: () {
//               if (_isNavigating) return; // Prevent multiple rapid taps
//
//               setState(() {
//                 _isNavigating = true;
//                 _headline = 'Job Openings';
//                 _isSidebarVisible = false;
//               });
//
//               WidgetsBinding.instance.addPostFrameCallback((_) async {
//                 await Navigator.of(context).push(
//                   MaterialPageRoute(builder: (context) => AttendanceFormPage()),
//                 );
//
//                 // After return from page, reset flag & rebuild items
//                 setState(() {
//                   _isNavigating = false;
//                   _items = _generateItems; // <--- Refresh sidebar items
//                 });
//               });
//             },
//             isSelected: false,
//           ),
//           CollapsibleItem(
//             text: 'Upload Resume',
//             icon: Icons.search,
//             onPressed: () {
//               if (_isNavigating) return; // Prevent multiple rapid taps
//
//               setState(() {
//                 _isNavigating = true;
//                 _headline = 'Upload Resume';
//                 _isSidebarVisible = false;
//               });
//
//               WidgetsBinding.instance.addPostFrameCallback((_) async {
//                 await Navigator.of(context).push(
//                   MaterialPageRoute(builder: (context) => AttendanceFormPage()),
//                 );
//
//                 // After return from page, reset flag & rebuild items
//                 setState(() {
//                   _isNavigating = false;
//                   _items = _generateItems; // <--- Refresh sidebar items
//                 });
//               });
//             },
//             isSelected: false,
//           ),
//         ],
//       ),
//       CollapsibleItem(
//         text: 'Log Out',
//         icon: Icons.search,
//         onPressed: () {
//           if (_isNavigating) return; // Prevent multiple rapid taps
//
//           setState(() {
//             _isNavigating = true;
//             _headline = 'Log Out';
//             _isSidebarVisible = false;
//           });
//
//           WidgetsBinding.instance.addPostFrameCallback((_) async {
//             await Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => AttendanceFormPage()),
//             );
//
//             // After return from page, reset flag & rebuild items
//             setState(() {
//               _isNavigating = false;
//               _items = _generateItems; // <--- Refresh sidebar items
//             });
//           });
//         },
//         isSelected: false,
//       ),
//     ];
//   }
//
//   Widget _body(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.blueGrey[50],
//       child: Center(
//         child: Text(
//           _headline,
//           style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Padding(
//           padding: const EdgeInsets.only(left: 65),
//           child: Text('Dashboard', style: TextStyle(color: Colors.white)),
//         ),
//         backgroundColor: Colors.blue.shade700,
//         elevation: 4,
//         leading: IconButton(
//           icon: Icon(
//             _isSidebarVisible ? Icons.close : Icons.menu,
//             color: Colors.white,
//           ),
//           onPressed: _toggleSidebar,
//         ),
//       ),
//       body: Stack(
//         children: [
//           _body(context),
//           if (_isSidebarVisible)
//             Positioned(
//               left: 0,
//               top: 0,
//               bottom: 0,
//               child: Container(
//                 width: 280,
//                 child: CollapsibleSidebar(
//                   isCollapsed: false,
//                   items: _items,
//                   collapseOnBodyTap: false,
//                   avatarImg: _avatarImg,
//                   title: 'Saurabh',
//                   body: Container(),
//                   backgroundColor: Colors.black,
//                   selectedTextColor: Colors.limeAccent,
//                   textStyle: TextStyle(fontSize: 16),
//                   titleStyle: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   toggleTitleStyle: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   sidebarBoxShadow: [
//                     BoxShadow(
//                       color: Colors.indigo,
//                       blurRadius: 20,
//                       spreadRadius: 0.01,
//                       offset: Offset(3, 3),
//                     ),
//                     BoxShadow(
//                       color: Colors.green,
//                       blurRadius: 50,
//                       spreadRadius: 0.01,
//                       offset: Offset(3, 3),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
