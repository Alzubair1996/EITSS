
# Project Brief: Convert Next.js Web App to a Standalone Windows Desktop Application

## 1. High-Level Objective

The primary goal is to convert the existing "Qareeb Store" web application, built with Next.js, into a self-contained, native desktop application for the Windows operating system. The final application must run locally without requiring the user to manually start a web server or open a web browser.

## 2. Current Application Architecture

The project is a modern web application with the following stack:

*   **Framework:** Next.js (App Router)
*   **Language:** TypeScript
*   **UI Library:** React with ShadCN UI components
*   **Styling:** Tailwind CSS
*   **Database:** A local SQLite database file (`balla.sqlite`)
*   **Backend Logic:** Handled by Next.js Server Actions, which directly query the SQLite database.

The application is fully functional as a web application running on `localhost`. The challenge is to package it for native desktop execution.

## 3. Recommended Desktop Framework: Tauri

To achieve this, we recommend using the **Tauri** framework.

**Why Tauri?**
*   **Lightweight:** It uses the operating system's native webview (Microsoft Edge's WebView2 on Windows), resulting in a significantly smaller application bundle size compared to alternatives like Electron.
*   **Performance:** Less memory consumption and faster startup times.
*   **Security:** Designed with security as a first principle, reducing risks associated with web-to-native applications.
*   **Compatibility:** It can seamlessly wrap the existing Next.js application.

(An alternative would be Electron, but Tauri is preferred for its efficiency.)

## 4. Key Technical Requirements & Implementation Steps

### Step 1: Integrate Tauri into the Existing Project
1.  **Set up the Tauri CLI:** Follow the official Tauri documentation to add Tauri to the existing `npm` project.
2.  **Configure `tauri.conf.json`:**
    *   **`build.devPath`**: This must be configured to point to the Next.js development server URL (e.g., `http://localhost:9002`).
    *   **`build.distDir`**: This must point to the output directory of the `next build` command, which is typically `../out` or `../.next`. Since Next.js App Router doesn't have a simple `next export` equivalent, you will need to run `next build` and configure Tauri to serve the `.next/standalone` output.
    *   **`identifier`**: Set a unique application identifier (e.g., `com.qareebstore.desktop`).
    *   **`windows`**: Configure window titles, icons, and initial dimensions.

### Step 2: Bridge the Next.js Server and Tauri Backend
The main challenge is running the Next.js server (which handles Server Actions and database access) within the Tauri application.

1.  **Sidecar Approach:** The most robust method is to package the Node.js runtime and the standalone Next.js server as a **Tauri Sidecar**.
    *   Run `next build`. This creates a production-ready `.next` directory. The standalone server can be run with `node .next/standalone/server.js`.
    *   Configure `tauri.conf.json` to bundle `node.exe` and the `.next/standalone` directory.
    *   Write a Rust script (in `src-tauri/main.rs`) to spawn the Node.js server as a background process when the Tauri app starts.
    *   The Tauri webview will then load the URL of this local server (e.g., `http://localhost:9002`).

### Step 3: Handle the SQLite Database
1.  **Database Location:** The SQLite database file (`balla.sqlite`) must be located in a user-writable directory. The Tauri `path` API should be used to resolve a path like the user's `appDataDir`.
2.  **Initialization:** The application code (`src/lib/db.ts`) must be modified to locate the database file in this new, correct location. The database should be created in this directory on the first run if it doesn't exist.

### Step 4: Build and Packaging
1.  **Icon:** Create a `.ico` file for the Windows application and reference it in `tauri.conf.json`.
2.  **Build Command:** Use the `tauri build` command. This will:
    *   Build the Next.js frontend.
    *   Compile the Rust backend.
    *   Bundle the Next.js standalone server and Node.js runtime (as a sidecar).
    *   Produce a native Windows installer (e.g., an `.msi` file).

## 5. Final Deliverable

The final output should be a single executable installer (`.msi` or `.exe`) for Windows. When a user runs this installer, it should install the "Qareeb Store" application. Launching the application from the Start Menu should open a native window displaying the application, with all functionality (inventory, sales, database access) working seamlessly and locally.
