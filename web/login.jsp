<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login/Signup</title>
    <link rel="stylesheet" type="text/css" href="CSS/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>
<body>
    <div class="container" id="container">
        <div class="form-container login-container">
            <div class="form">
                <h2>Login</h2>
                <form action="LoginServlet" method="post" id="loginForm">
                    <div class="input-login">
                        <input type="email" name="email" placeholder="Email" required />
                    </div>
                    <div class="input-login">
                        <input type="password" name="password" placeholder="Password" required />
                    </div>
                    <button type="submit">Login</button>
                </form>
                <div class="toggle-form">
                    New user? <a id="signup-toggle">Register here</a>
                </div>
                <% String loginError = request.getParameter("error"); %>
                <% if (loginError != null) { %>
                    <p class="error-message"><%= loginError %></p>
                <% } %>
                <% String loginSuccess = request.getParameter("success"); %>
                <% if (loginSuccess != null) { %>
                    <p class="success-message"><%= loginSuccess %></p>
                <% } %>
            </div>
        </div>
        
        <div class="form-container signup-container">
            <div class="form">
                <h2>Sign Up</h2>
                <form action="SignupServlet" method="post" id="signupForm">
                    <div class="input-wrapper">
                        <input type="text" name="name" placeholder="Name" required />
                    </div>
                    <div class="input-wrapper">
                        <input type="email" name="email" placeholder="Email" required />
                    </div>
                    <div class="input-wrapper">
                        <input type="password" name="password" id="password" placeholder="Password" required />
                        <small class="password-requirement-hint">Must include: 8+ chars, 1 uppercase, 1 lowercase, 1 digit & 1 special symbol.</small>
                        <div class="password-strength">
                            <div class="strength-meter" id="strengthMeter"></div>
                        </div>
                    </div>
                    <div class="input-wrapper">
                        <input type="password" name="confirm" id="confirmPassword" placeholder="Confirm Password" required />
                        <span class="validation-icon" id="confirmPasswordIcon"></span>
                    </div>
                    <p class="error-message" id="passwordMatchError" style="display:none;">Passwords do not match</p>
                    
                    <div class="role-selection">
                        <label>
                            <input type="radio" name="role" value="employee" checked> Employee
                        </label>
                        <label>
                            <input type="radio" name="role" value="admin"> Admin
                        </label>
                    </div>
                    
                    <select name="department" id="departmentSelect" required>
                        <option value="">-- Select Department --</option>
                        <option value="Web Development">Web Development</option>
                        <option value="Frontend">Frontend</option>
                        <option value="Backend">Backend</option>
                        <option value="Full Stack">Full Stack</option>
                        <option value="UI/UX Design">UI/UX Design</option>
                        <option value="Mobile App Development">Mobile App Development</option>
                        <option value="QA/Testing">QA/Testing</option>
                        <option value="DevOps">DevOps</option>
                        <option value="IT Support">IT Support</option>
                        <option value="Project Management">Project Management</option>
                        <option value="Business Analysis">Business Analysis</option>
                        <option value="Product Management">Product Management</option>
                        <option value="HR">HR</option>
                        <option value="Sales">Sales</option>
                        <option value="Digital Marketing">Digital Marketing</option>
                        <option value="Content Writing">Content Writing</option>
                        <option value="Finance">Finance</option>
                    </select>
                  
                    <button type="submit" id="signupButton">Sign Up</button>
                </form>
                <div class="toggle-form">
                    Already have an account? <a id="login-toggle">Login here</a>
                </div>
                <% String signupError = request.getParameter("error"); %>
                <% if (signupError != null) { %>
                    <p class="error-message"><%= signupError %></p>
                <% } %>
                <% String signupSuccess = request.getParameter("success"); %>
                <% if (signupSuccess != null) { %>
                    <p class="success-message"><%= signupSuccess %></p>
                <% } %>
            </div>
        </div>
        
        <div class="overlay-container">
            <div class="overlay">
                <div class="overlay-panel overlay-left">
                    <h2>Welcome Back!</h2>
                    <p>To keep connected with us please login with your personal info</p>
                    <button class="ghost" id="login-switch">Login</button>
                </div>
                <div class="overlay-panel overlay-right">
                    <h2>Hello, Friend!</h2>
                    <p>Enter your personal details and start journey with us</p>
                    <button class="ghost" id="signup-switch">Sign Up</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Background particles -->
    <div class="particles" id="particles"></div>

    <script>
        // Form toggle functionality
        const signupToggle = document.getElementById('signup-toggle');
        const loginToggle = document.getElementById('login-toggle');
        const signupSwitch = document.getElementById('signup-switch');
        const loginSwitch = document.getElementById('login-switch');
        const container = document.getElementById('container');
        
        signupToggle.addEventListener('click', () => {
            container.classList.add('right-panel-active');
        });
        
        loginToggle.addEventListener('click', () => {
            container.classList.remove('right-panel-active');
        });
        
        signupSwitch.addEventListener('click', () => {
            container.classList.add('right-panel-active');
        });
        
        loginSwitch.addEventListener('click', () => {
            container.classList.remove('right-panel-active');
        });

        // Particles animation
        const particlesContainer = document.getElementById('particles');
        const particleCount = 30;
        
        for (let i = 0; i < particleCount; i++) {
            const particle = document.createElement('div');
            particle.classList.add('particle');
            
            const size = Math.random() * 5 + 1;
            const posX = Math.random() * window.innerWidth;
            const delay = Math.random() * 15;
            const duration = Math.random() * 10 + 10;
            
            particle.style.width = `${size}px`;
            particle.style.height = `${size}px`;
            particle.style.left = `${posX}px`;
            particle.style.bottom = `-10px`;
            particle.style.animationDelay = `${delay}s`;
            particle.style.animationDuration = `${duration}s`;
            particle.style.opacity = Math.random() * 0.5 + 0.1;
            
            particlesContainer.appendChild(particle);
        }

        // Password validation
        const passwordInput = document.getElementById('password');
        const confirmPasswordInput = document.getElementById('confirmPassword');
        const passwordMatchError = document.getElementById('passwordMatchError');
        const confirmPasswordIcon = document.getElementById('confirmPasswordIcon');
        const signupForm = document.getElementById('signupForm');
        const strengthMeter = document.getElementById('strengthMeter');

        function validatePassword(password) {
            const hasLength = password.length >= 8;
            const hasUpper = /[A-Z]/.test(password);
            const hasLower = /[a-z]/.test(password);
            const hasNumber = /[0-9]/.test(password);
            const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
            
            // Calculate strength
            let strength = 0;
            if (hasLength) strength++;
            if (hasUpper) strength++;
            if (hasLower) strength++;
            if (hasNumber) strength++;
            if (hasSpecial) strength++;
            
            // Update strength meter
            const strengthPercent = (strength / 5) * 100;
            strengthMeter.style.width = `${strengthPercent}%`;
            
            // Set color based on strength
            if (strength <= 2) {
                strengthMeter.style.backgroundColor = '#ff4d4d';
            } else if (strength <= 4) {
                strengthMeter.style.backgroundColor = '#ffcc00';
            } else {
                strengthMeter.style.backgroundColor = '#4CAF50';
            }
            
            return {
                isValid: hasLength && hasUpper && hasLower && hasNumber && hasSpecial,
                missingRequirements: [
                    !hasLength ? "At least 8 characters" : null,
                    !hasUpper ? "At least 1 uppercase letter" : null,
                    !hasLower ? "At least 1 lowercase letter" : null,
                    !hasNumber ? "At least 1 number" : null,
                    !hasSpecial ? "At least 1 special character (!@#$%^&* etc.)" : null
                ].filter(Boolean)
            };
        }

        function checkPasswordMatch() {
            const password = passwordInput.value;
            const confirmPassword = confirmPasswordInput.value;
            
            if (confirmPassword === '') {
                passwordMatchError.style.display = 'none';
                confirmPasswordIcon.style.display = 'none';
                return false;
            }
            
            const isMatch = password === confirmPassword;
            
            if (isMatch) {
                passwordMatchError.style.display = 'none';
                confirmPasswordIcon.className = 'validation-icon valid';
                confirmPasswordIcon.innerHTML = '<i class="fas fa-check"></i>';
                confirmPasswordIcon.style.display = 'inline-block';
            } else {
                passwordMatchError.style.display = 'block';
                confirmPasswordIcon.className = 'validation-icon invalid';
                confirmPasswordIcon.innerHTML = '<i class="fas fa-times"></i>';
                confirmPasswordIcon.style.display = 'inline-block';
            }
            
            return isMatch;
        }

        // Role selection change handler
        const roleRadios = document.querySelectorAll('input[name="role"]');
        const departmentSelect = document.getElementById('departmentSelect');

        function handleRoleChange() {
            const selectedRole = document.querySelector('input[name="role"]:checked').value;
            if (selectedRole === 'admin') {
                departmentSelect.disabled = true;
                departmentSelect.required = false;
                departmentSelect.value = ''; // Clear the selection
            } else {
                departmentSelect.disabled = false;
                departmentSelect.required = true;
            }
        }

        // Add event listeners to role radio buttons
        roleRadios.forEach(radio => {
            radio.addEventListener('change', handleRoleChange);
        });

        // Initialize the state on page load
        handleRoleChange();

        // Real-time validation
        passwordInput.addEventListener('input', function() {
            validatePassword(this.value);
            if (confirmPasswordInput.value !== '') {
                checkPasswordMatch();
            }
        });

        confirmPasswordInput.addEventListener('input', checkPasswordMatch);

        signupForm.addEventListener('submit', function(e) {
            const password = passwordInput.value;
            const isPasswordMatch = checkPasswordMatch();
            const passwordValidation = validatePassword(password);
            
            if (!passwordValidation.isValid || !isPasswordMatch) {
                e.preventDefault();
                
                if (!passwordValidation.isValid) {
                    passwordInput.focus();
                } else if (!isPasswordMatch) {
                    confirmPasswordInput.focus();
                }
            }
        });
    </script>
</body>
</html>