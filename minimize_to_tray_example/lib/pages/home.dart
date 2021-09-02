import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

final trayManager = TrayManager.instance;
final windowManager = WindowManager.instance;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener, WindowListener {
  bool _smallWindow = false;
  bool _removeIconAfterRestored = false;
  bool _showWindowBelowTrayIcon = false;

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  void _handleClickMinimize() async {
    windowManager.minimize();
  }

  void _handleClickRestore() async {
    windowManager.restore();
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          children: [
            PreferenceListItem(
              title: Text('Minimize'),
              onTap: _handleClickMinimize,
            ),
          ],
        ),
        PreferenceListSection(
          title: Text('Option'),
          children: [
            PreferenceListSwitchItem(
              value: _removeIconAfterRestored,
              onChanged: (newValue) {
                _removeIconAfterRestored = newValue;
                setState(() {});
              },
              title: Text('Remove icon after restored'),
            ),
            if (!_removeIconAfterRestored)
              PreferenceListSwitchItem(
                value: _showWindowBelowTrayIcon,
                onChanged: (newValue) {
                  _showWindowBelowTrayIcon = newValue;
                  setState(() {});
                },
                title: Text('Show window below tray icon'),
              ),
            PreferenceListSwitchItem(
              value: _smallWindow,
              onChanged: (newValue) {
                _smallWindow = newValue;
                setState(() {});
                if (_smallWindow) {
                  windowManager.setSize(Size(380, 400));
                } else {
                  windowManager.setSize(Size(400, 600));
                }
              },
              title: Text('Small window'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void onTrayIconMouseUp() async {
    if (_showWindowBelowTrayIcon) {
      Size windowSize = await windowManager.getSize();
      Rect trayIconBounds = await trayManager.getBounds();
      Size trayIconSize = trayIconBounds.size;
      Offset trayIconnewPosition = trayIconBounds.topLeft;

      Offset newPosition = Offset(
        trayIconnewPosition.dx - ((windowSize.width - trayIconSize.width) / 2),
        trayIconnewPosition.dy,
      );

      windowManager.setPosition(newPosition);
      await Future.delayed(Duration(milliseconds: 100));
    }
    _handleClickRestore();
  }

  @override
  void onTrayIconRightMouseUp() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    print(menuItem.toJson());
  }

  @override
  void onWindowMinimize() async {
    await trayManager.setIcon('images/tray_icon.png');
    List<MenuItem> menuItems = [
      MenuItem(title: 'Exit'),
    ];
    await trayManager.setContextMenu(menuItems);
  }

  @override
  void onWindowRestore() async {
    if (_removeIconAfterRestored) {
      await trayManager.destroy();
    }
  }
}
