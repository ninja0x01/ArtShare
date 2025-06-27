<?php
session_start();

// Database configuration
$host = 'localhost';
$dbname = 'artshare_db';
$dbuser = 'root';
$dbpass = '';

// Initialize variables
$error = '';
$success = false;
$email = '';

// Check if PDO is available
if (!extension_loaded('pdo')) {
    $error = 'PDO extension is not enabled on this server';
} else {
    // Process login form if submitted
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        try {
            // Create PDO connection (without ERRMODE_EXCEPTION first)
            $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $dbuser, $dbpass);
            
            // Set error mode only if the constant exists
            if (defined('PDO::ATTR_ERRMODE')) {
                $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            }

            // Get form data
            $email = trim($_POST['email']);
            $password = $_POST['password'];

            // Validate inputs
            if (empty($email) || empty($password)) {
                $error = 'Please enter both email and password';
            } else {
                // Prepare SQL to get user
                $stmt = $pdo->prepare("SELECT id, username, email, password_hash, profile_image FROM users WHERE email = ?");
                $stmt->execute([$email]);
                $user = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($user && password_verify($password, $user['password_hash'])) {
                    // Login successful
                    $_SESSION['user'] = [
                        'id' => $user['id'],
                        'username' => $user['username'],
                        'email' => $user['email'],
                        'profile_image' => $user['profile_image']
                    ];
                    $success = true;
                } else {
                    $error = 'Invalid email or password';
                }
            }
        } catch (Exception $e) {
            $error = 'Database error. Please try again later.';
            error_log("Login error: " . $e->getMessage());
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login • ArtShare</title>
    <style>
        :root {
            --primary: #6366f1;
            --primary-dark: #4f46e5;
            --error: #ef4444;
            --success: #10b981;
            --text: #1f2937;
            --text-light: #6b7280;
            --border: #e5e7eb;
        }
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: #f9fafb;
            color: var(--text);
            display: grid;
            place-items: center;
            min-height: 100vh;
            padding: 1rem;
        }
        .card {
            width: 100%;
            max-width: 400px;
            background: white;
            border-radius: 1rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .header {
            padding: 2rem;
            text-align: center;
            border-bottom: 1px solid var(--border);
        }
        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 0.5rem;
        }
        .subtitle {
            color: var(--text-light);
            font-size: 0.875rem;
        }
        .form {
            padding: 2rem;
        }
        .form-group {
            margin-bottom: 1.25rem;
        }
        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text);
        }
        .form-input {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid var(--border);
            border-radius: 0.5rem;
            font-size: 1rem;
        }
        .form-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }
        .btn {
            width: 100%;
            padding: 0.75rem;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 0.5rem;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            margin-top: 1rem;
        }
        .btn:hover {
            background: var(--primary-dark);
        }
        .alert {
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
            font-size: 0.875rem;
        }
        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            color: var(--error);
            border-left: 3px solid var(--error);
        }
        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success);
            border-left: 3px solid var(--success);
        }
        .footer {
            padding: 1.5rem;
            text-align: center;
            border-top: 1px solid var(--border);
            font-size: 0.875rem;
            color: var(--text-light);
        }
        .footer a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
        }
        .footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="header">
            <div class="logo">ArtShare</div>
            <p class="subtitle">Sign in to your account</p>
        </div>

        <?php if ($error): ?>
            <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>

        <?php if ($success): ?>
            <div class="alert alert-success">
                Login successful! Redirecting...
                <script>
                    setTimeout(() => {
                        window.location.href = 'dashboard.php';
                    }, 1500);
                </script>
            </div>
        <?php else: ?>

        <form class="form" method="POST">
            <div class="form-group">
                <label for="email" class="form-label">Email</label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    class="form-input" 
                    placeholder="you@example.com" 
                    value="<?= htmlspecialchars($email) ?>" 
                    required
                >
            </div>

            <div class="form-group">
                <label for="password" class="form-label">Password</label>
                <input 
                    type="password" 
                    id="password" 
                    name="password" 
                    class="form-input" 
                    placeholder="••••••••" 
                    required
                >
            </div>

            <button type="submit" class="btn">Sign In</button>
        </form>

        <?php endif; ?>

        <div class="footer">
            Don't have an account? <a href="register.php">Sign up</a>
        </div>
    </div>
</body>
</html>