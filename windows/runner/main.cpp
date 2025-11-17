#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ PWSTR cmd_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);

  // --- Custom Configuration for Icon ---
  // Load the application icon from the resources.
  // You need to create an `app_icon.ico` file and add it to `windows/runner/resources/`.
  // Also, you need a `runner.rc` file to define the resource.
  const HICON icon = static_cast<HICON>(
      LoadImage(GetModuleHandle(nullptr), L"IDI_APP_ICON", IMAGE_ICON,
                GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON),
                LR_DEFAULTCOLOR));
  // --- End of Custom Configuration ---

  if (!window.Create(L"digital_clock", origin, size)) {
    return EXIT_FAILURE;
  }

  // --- Set the loaded icon for the window ---
  if (icon) {
      SendMessage(window.GetHandle(), WM_SETICON, ICON_SMALL, (LPARAM)icon);
      SendMessage(window.GetHandle(), WM_SETICON, ICON_BIG, (LPARAM)icon);
  }
  // --- End of setting icon ---

  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

