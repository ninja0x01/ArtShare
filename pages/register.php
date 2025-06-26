<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign up • ArtShare</title>
    <link rel="stylesheet" href="../assets\css\register.css">
</head>
<body>
    <div class="container">
        <div class="signup-wrapper">
            <div class="signup-box" id="signupBox">
                <div class="logo">ArtShare</div>
                
                <div class="progress-bar">
                    <div class="progress-fill" id="progressFill"></div>
                </div>
                
                <form id="signupForm" action="signup.php" method="POST" enctype="multipart/form-data">
                    <!-- Step 1: Basic Information -->
                    <div class="form-step active" id="step1">
                        <div class="section-title">Welcome to ArtShare</div>
                        <div class="section-subtitle">Let's get started with your basic information</div>
                        
                        <div class="form-group">
                            <input type="text" name="username" class="form-input" placeholder="Choose a username" required>
                        </div>
                        <div class="form-group">
                            <input type="email" name="email" class="form-input" placeholder="Your email address" required>
                        </div>
                        <div class="form-group">
                            <input type="password" name="password" class="form-input" placeholder="Create a strong password" required>
                        </div>
                        
                        <div class="button-group">
                            <button type="button" class="btn btn-primary" id="nextBtn1">Continue</button>
                        </div>
                    </div>

                    <!-- Step 2: Profile Information -->
                    <div class="form-step" id="step2">
                        <div class="section-title">Build Your Profile</div>
                        <div class="section-subtitle">Tell us about yourself and upload a profile picture</div>
                        
                        <div class="form-group">
                            <input type="text" name="first_name" class="form-input" placeholder="First Name">
                        </div>
                        <div class="form-group">
                            <input type="text" name="last_name" class="form-input" placeholder="Last Name">
                        </div>
                        <div class="form-group">
                            <textarea name="bio" class="form-textarea" placeholder="Tell us about your artistic journey..."></textarea>
                        </div>
                        <div class="form-group">
                            <div class="file-input-wrapper">
                                <input type="file" name="profile_image_upload" class="file-input" id="profileImage" accept="image/*">
                                <label for="profileImage" class="file-input-label" id="fileLabel">📸 Choose profile image</label>
                            </div>
                        </div>
                        
                        <div class="button-group">
                            <button type="button" class="btn btn-secondary" id="prevBtn2">Back</button>
                            <button type="button" class="btn btn-primary" id="nextBtn2">Continue</button>
                        </div>
                    </div>

                    <!-- Step 3: Contact & Links -->
                    <div class="form-step" id="step3">
                        <div class="section-title">Connect & Share</div>
                        <div class="section-subtitle">Add your location, website, and social links</div>
                        
                        <div class="form-group">
                            <input type="text" name="location" class="form-input" placeholder="📍 Your location">
                        </div>
                        <div class="form-group">
                            <input type="url" name="website" class="form-input" placeholder="🌐 Your website URL">
                        </div>
                        <div class="form-group">
                            <input type="url" name="portfolio_url" class="form-input" placeholder="🎨 Portfolio URL">
                        </div>
                        <div class="form-group">
                            <textarea name="social_links" class="form-textarea" placeholder="📱 Social links (Instagram, Facebook, Twitter)"></textarea>
                        </div>
                        
                        <div class="button-group">
                            <button type="button" class="btn btn-secondary" id="prevBtn3">Back</button>
                            <button type="button" class="btn btn-primary" id="nextBtn3">Continue</button>
                        </div>
                    </div>

                    <!-- Step 4: Personal Details -->
                    <div class="form-step" id="step4">
                        <div class="section-title">Final Details</div>
                        <div class="section-subtitle">Just a few more details to complete your profile</div>
                        
                        <div class="form-group">
                            <input type="date" name="date_of_birth" class="form-input">
                        </div>
                        <div class="form-group">
                            <select name="gender" class="form-select">
                                <option value="">Select Gender</option>
                                <option value="male">Male</option>
                                <option value="female">Female</option>
                                <option value="other">Other</option>
                                <option value="prefer_not_to_say">Prefer Not to Say</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <input type="text" name="art_styles" class="form-input" placeholder="🎭 Art styles (painting, digital, sculpture)">
                        </div>
                        <div class="checkbox-group">
                            <input type="checkbox" name="is_profile_private" value="1" class="checkbox-input" id="privateProfile">
                            <label for="privateProfile" class="checkbox-label">🔒 Make my profile private</label>
                        </div>
                        
                        <div class="button-group">
                            <button type="button" class="btn btn-secondary" id="prevBtn4">Back</button>
                            <button type="submit" class="btn btn-primary" id="submitBtn">
                                <span id="submitText">Create Account</span>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            
            <div class="login-box">
                Already have an account? <a href="login.php" class="login-link">Log in</a>
            </div>
        </div>
    </div>

    <script>
        let currentStep = 1;
        const totalSteps = 4;

        // File input handling
        document.getElementById('profileImage').addEventListener('change', function() {
            const fileLabel = document.getElementById('fileLabel');
            if (this.files && this.files[0]) {
                fileLabel.textContent = `📸 ${this.files[0].name}`;
                fileLabel.style.color = '#6366f1';
            } else {
                fileLabel.textContent = '📸 Choose profile image';
            }
        });

        // Progress bar update
        function updateProgress() {
            const progressFill = document.getElementById('progressFill');
            const percentage = (currentStep / totalSteps) * 100;
            progressFill.style.width = percentage + '%';
        }

        // Show step with animation
        function showStep(stepNumber) {
            const allSteps = document.querySelectorAll('.form-step');
            const signupBox = document.getElementById('signupBox');
            const currentStepEl = document.getElementById(`step${currentStep}`);
            const targetStep = document.getElementById(`step${stepNumber}`);
            
            // Determine animation direction
            const isGoingBack = stepNumber < currentStep;
            
            // Add sliding animation to current step
            if (currentStepEl) {
                currentStepEl.style.transform = isGoingBack ? 'translateX(50px)' : 'translateX(-50px)';
                currentStepEl.style.opacity = '0';
            }
            
            signupBox.classList.add('sliding');
            
            setTimeout(() => {
                // Hide all steps
                allSteps.forEach(step => {
                    step.classList.remove('active', 'prev');
                    step.style.display = 'none';
                    step.style.transform = '';
                    step.style.opacity = '';
                });
                
                // Show target step with appropriate animation
                targetStep.style.display = 'block';
                targetStep.style.transform = isGoingBack ? 'translateX(-50px)' : 'translateX(50px)';
                targetStep.style.opacity = '0';
                
                // Force reflow
                targetStep.offsetHeight;
                
                // Animate in
                targetStep.style.transition = 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)';
                targetStep.classList.add('active');
                targetStep.style.transform = 'translateX(0)';
                targetStep.style.opacity = '1';
                
                signupBox.classList.remove('sliding');
                
                // Update progress
                currentStep = stepNumber;
                updateProgress();
                
                // Reset transition after animation
                setTimeout(() => {
                    targetStep.style.transition = '';
                }, 400);
                
            }, 150);
        }

        // Form validation for each step
        function validateStep(stepNumber) {
            const step = document.getElementById(`step${stepNumber}`);
            const requiredInputs = step.querySelectorAll('input[required]');
            
            for (let input of requiredInputs) {
                if (!input.value.trim()) {
                    input.focus();
                    input.style.borderColor = '#e74c3c';
                    setTimeout(() => {
                        input.style.borderColor = 'rgba(0, 0, 0, 0.1)';
                    }, 3000);
                    return false;
                }
                
                // Email validation
                if (input.type === 'email') {
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailRegex.test(input.value)) {
                        input.focus();
                        input.style.borderColor = '#e74c3c';
                        alert('Please enter a valid email address');
                        return false;
                    }
                }
                
                // Password validation
                if (input.type === 'password' && input.value.length < 6) {
                    input.focus();
                    input.style.borderColor = '#e74c3c';
                    alert('Password must be at least 6 characters long');
                    return false;
                }
                
                // Username validation
                if (input.name === 'username' && input.value.length < 3) {
                    input.focus();
                    input.style.borderColor = '#e74c3c';
                    alert('Username must be at least 3 characters long');
                    return false;
                }
            }
            
            return true;
        }

        // Next button handlers
        document.getElementById('nextBtn1').addEventListener('click', function() {
            if (validateStep(1)) {
                showStep(2);
            }
        });

        document.getElementById('nextBtn2').addEventListener('click', function() {
            showStep(3);
        });

        document.getElementById('nextBtn3').addEventListener('click', function() {
            showStep(4);
        });

        // Previous button handlers
        document.getElementById('prevBtn2').addEventListener('click', function() {
            showStep(1);
        });

        document.getElementById('prevBtn3').addEventListener('click', function() {
            showStep(2);
        });

        document.getElementById('prevBtn4').addEventListener('click', function() {
            showStep(3);
        });

        // Form submission
        document.getElementById('signupForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const submitBtn = document.getElementById('submitBtn');
            const submitText = document.getElementById('submitText');
            
            // Show loading state
            submitBtn.disabled = true;
            submitText.innerHTML = '<div class="loading"></div>Creating Account...';
            
            // Simulate form submission (replace with actual submission)
            setTimeout(() => {
                const signupBox = document.getElementById('signupBox');
                signupBox.classList.add('success-animation');
                submitText.textContent = '🎉 Account Created!';
                
                setTimeout(() => {
                    // Redirect or show success message
                    alert('Welcome to ArtShare! Your account has been created successfully.');
                    // window.location.href = 'welcome.php';
                }, 1000);
            }, 2000);
        });

        // Input focus animations
        document.querySelectorAll('.form-input, .form-select, .form-textarea').forEach(input => {
            input.addEventListener('focus', function() {
                this.parentElement.style.transform = 'scale(1.02)';
            });
            
            input.addEventListener('blur', function() {
                this.parentElement.style.transform = 'scale(1)';
            });
        });

        // Keyboard navigation
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && e.target.classList.contains('form-input')) {
                e.preventDefault();
                const nextButton = document.querySelector(`#nextBtn${currentStep}`);
                if (nextButton) {
                    nextButton.click();
                }
            }
        });

        // Initialize
        updateProgress();
    </script>
</body>
</html>