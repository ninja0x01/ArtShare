<?php
// Database configuration
$host = 'localhost';
$dbname = 'artshare_db';
$dbuser = 'root';
$dbpass = '';

// Start session
session_start();

// Initialize variables
$error = '';
$success = false;
$pdo = null;
$username = '';
$email = '';

// Check if PDO is available
if (!extension_loaded('pdo') || !extension_loaded('pdo_mysql')) {
    $error = 'PDO MySQL extension is not enabled on this server';
} else {
    // Process form submission
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        try {
            // Create database connection
            $pdo = new PDO("mysql:host=$host;dbname=$dbname", $dbuser, $dbpass);
            
            // Set error mode
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

            // Get and sanitize form data
            $username = trim($_POST['username'] ?? '');
            $email = trim($_POST['email'] ?? '');
            $password = $_POST['password'] ?? '';

            // Validate inputs
            $validationErrors = [];
            
            if (empty($username)) {
                $validationErrors[] = 'Username is required';
            } elseif (strlen($username) < 3) {
                $validationErrors[] = 'Username must be at least 3 characters';
            } elseif (!preg_match('/^[a-zA-Z0-9_]+$/', $username)) {
                $validationErrors[] = 'Username can only contain letters, numbers, and underscores';
            }

            if (empty($email)) {
                $validationErrors[] = 'Email is required';
            } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $validationErrors[] = 'Please enter a valid email';
            }

            if (empty($password)) {
                $validationErrors[] = 'Password is required';
            } elseif (strlen($password) < 6) {
                $validationErrors[] = 'Password must be at least 6 characters';
            }

            if (!empty($validationErrors)) {
                $error = implode('<br>', $validationErrors);
            } else {
                // Check if user exists
                $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ? OR username = ?");
                $stmt->execute([$email, $username]);
                
                if ($stmt->fetch()) {
                    $error = 'Username or email already exists';
                } else {
                    // Handle file upload
                    $profile_image = null;
                    if (isset($_FILES['profile_image']) && $_FILES['profile_image']['error'] === UPLOAD_ERR_OK) {
                        $upload_dir = 'uploads/';
                        if (!is_dir($upload_dir)) {
                            if (!mkdir($upload_dir, 0755, true)) {
                                throw new Exception('Failed to create upload directory');
                            }
                        }
                        
                        // Validate image
                        $finfo = new finfo(FILEINFO_MIME_TYPE);
                        $mime = $finfo->file($_FILES['profile_image']['tmp_name']);
                        $allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
                        
                        if (!in_array($mime, $allowed)) {
                            throw new Exception('Invalid file type. Only images are allowed.');
                        }

                        $ext = pathinfo($_FILES['profile_image']['name'], PATHINFO_EXTENSION);
                        $filename = uniqid('profile_', true) . '.' . $ext;
                        $target_path = $upload_dir . $filename;
                        
                        if (move_uploaded_file($_FILES['profile_image']['tmp_name'], $target_path)) {
                            $profile_image = $target_path;
                        } else {
                            throw new Exception('Failed to upload image');
                        }
                    }

                    // Hash password
                    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
                    if ($hashed_password === false) {
                        throw new Exception('Password hashing failed');
                    }

                    // Insert user transaction
                    $pdo->beginTransaction();
                    
                    try {
                        $stmt = $pdo->prepare("INSERT INTO users 
                            (username, email, password_hash, profile_image, created_at, updated_at) 
                            VALUES (?, ?, ?, ?, NOW(), NOW())");
                        
                        if (!$stmt->execute([$username, $email, $hashed_password, $profile_image])) {
                            throw new Exception('Failed to create user');
                        }

                        $user_id = $pdo->lastInsertId();
                        $pdo->commit();

                        // Store user in session
                        $_SESSION['user'] = [
                            'id' => $user_id,
                            'username' => $username,
                            'email' => $email,
                            'profile_image' => $profile_image
                        ];
                        
                        $success = true;
                    } catch (Exception $e) {
                        $pdo->rollBack();
                        throw $e;
                    }
                }
            }
        } catch (PDOException $e) {
            $error = 'Database error: ' . $e->getMessage();
            error_log("PDO Error: " . $e->getMessage());
        } catch (Exception $e) {
            $error = 'Error: ' . $e->getMessage();
            error_log("General Error: " . $e->getMessage());
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign up • ArtShare</title>
    <style>
        :root {
            --primary: #6366f1;
            --primary-light: #818cf8;
            --primary-dark: #4f46e5;
            --gray-100: #f3f4f6;
            --gray-200: #e5e7eb;
            --gray-400: #9ca3af;
            --gray-600: #4b5563;
            --gray-800: #1f2937;
            --error: #ef4444;
            --success: #10b981;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, sans-serif;
            background-color: var(--gray-100);
            color: var(--gray-800);
            display: grid;
            place-items: center;
            min-height: 100vh;
            padding: 1rem;
            line-height: 1.5;
        }
        
        .card {
            width: 100%;
            max-width: 420px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            overflow: hidden;
            animation: fadeIn 0.3s ease-out;
        }
        
        .header {
            padding: 2rem 2rem 1rem;
            text-align: center;
        }
        
        .logo {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin-bottom: 0.5rem;
        }
        
        .subtitle {
            color: var(--gray-600);
            font-size: 0.95rem;
        }
        
        .form {
            padding: 1.5rem 2rem 2rem;
        }
        
        .form-group {
            margin-bottom: 1.25rem;
        }
        
        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--gray-600);
        }
        
        .form-input {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid var(--gray-200);
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.2s;
        }
        
        .form-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }
        
        .file-upload {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 1.25rem;
            border: 2px dashed var(--gray-200);
            border-radius: 8px;
            margin-bottom: 1.5rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .file-upload:hover {
            border-color: var(--primary-light);
            background-color: rgba(99, 102, 241, 0.05);
        }
        
        .file-upload input {
            display: none;
        }
        
        .file-upload-icon {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
            color: var(--primary);
        }
        
        .file-upload-text {
            font-size: 0.875rem;
            color: var(--gray-600);
            text-align: center;
        }
        
        .file-upload-text span {
            color: var(--primary);
            font-weight: 500;
        }
        
        .btn {
            width: 100%;
            padding: 0.875rem;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
        }
        
        .alert {
            padding: 0.875rem;
            border-radius: 8px;
            margin-bottom: 1.25rem;
            font-size: 0.875rem;
            border-left: 3px solid;
            display: none;
        }
        
        .alert-error {
            background: rgba(239, 68, 68, 0.08);
            color: var(--error);
            border-color: var(--error);
        }
        
        .alert-success {
            background: rgba(16, 185, 129, 0.08);
            color: var(--success);
            border-color: var(--success);
        }
        
        .footer {
            padding: 1.25rem 2rem;
            border-top: 1px solid var(--gray-200);
            text-align: center;
            font-size: 0.875rem;
            color: var(--gray-600);
        }
        
        .footer a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
        }
        
        .footer a:hover {
            text-decoration: underline;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="header">
            <div class="logo">ArtShare</div>
            <p class="subtitle">Create your artist account</p>
        </div>

        <?php if ($error): ?>
            <div class="alert alert-error" id="errorAlert"><?= $error ?></div>
        <?php endif; ?>
        
        <?php if ($success): ?>
            <div class="alert alert-success" id="successAlert">
                Account created successfully! Redirecting...
            </div>
            <script>
                setTimeout(() => {
                    window.location.href = 'dashboard.php';
                }, 2000);
            </script>
        <?php elseif (!extension_loaded('pdo') || !extension_loaded('pdo_mysql')): ?>
            <div class="alert alert-error">
                System Error: PDO MySQL extension is required but not enabled. Please contact your server administrator.
            </div>
        <?php else: ?>

        <form class="form" method="POST" enctype="multipart/form-data" id="registerForm">
            <div class="form-group">
                <label for="username" class="form-label">Username</label>
                <input 
                    type="text" 
                    id="username" 
                    name="username" 
                    class="form-input" 
                    placeholder="yourname" 
                    value="<?= htmlspecialchars($username) ?>" 
                    required
                    pattern="[a-zA-Z0-9_]+"
                    title="Only letters, numbers, and underscores allowed"
                >
                <small class="form-hint">3+ characters, letters, numbers, underscores only</small>
            </div>

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
                    minlength="6"
                >
                <small class="form-hint">Minimum 6 characters</small>
            </div>

            <label class="file-upload">
                <input type="file" id="profileImage" name="profile_image" accept="image/*">
                <div class="file-upload-icon">📷</div>
                <div class="file-upload-text" id="fileLabel">
                    <span>Upload profile photo</span> (optional, max 2MB)
                </div>
            </label>

            <button type="submit" class="btn" id="submitBtn">Create Account</button>
        </form>

        <?php endif; ?>

        <div class="footer">
            Already have an account? <a href="login.php">Sign in</a>
        </div>
    </div>

    <script>
        // Client-side validation
        document.getElementById('registerForm')?.addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const submitBtn = document.getElementById('submitBtn');
            
            // Simple client-side validation
            if (password.length < 6) {
                e.preventDefault();
                alert('Password must be at least 6 characters');
                return;
            }
            
            // Disable button to prevent double submission
            submitBtn.disabled = true;
            submitBtn.innerHTML = 'Creating account...';
        });

        // Show selected filename and validate size
        document.getElementById('profileImage')?.addEventListener('change', function() {
            const fileLabel = document.getElementById('fileLabel');
            if (this.files && this.files[0]) {
                // Check file size (max 2MB)
                if (this.files[0].size > 2 * 1024 * 1024) {
                    alert('File size must be less than 2MB');
                    this.value = '';
                    fileLabel.innerHTML = '<span>Upload profile photo</span> (optional, max 2MB)';
                } else {
                    fileLabel.innerHTML = `<span>${this.files[0].name}</span>`;
                }
            } else {
                fileLabel.innerHTML = '<span>Upload profile photo</span> (optional, max 2MB)';
            }
        });

        // Auto-hide alerts after 5 seconds
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            setTimeout(() => {
                alert.style.display = 'none';
            }, 5000);
        });
    </script>
</body>
</html>