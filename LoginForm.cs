using System.Drawing.Drawing2D;

namespace Ticket_Dashboard
{
    
    public partial class LoginForm : Form
    {
        
        private TextBox usernameBox;
        private TextBox passwordBox;
        private Button submitButton;
        private Button setupAccountButton;

        private void LoginForm_Paint(object sender, PaintEventArgs e)
        {
            LinearGradientBrush brush = new LinearGradientBrush(
            this.ClientRectangle,
            Color.FromArgb(60, 60, 60),   // dark gray
            Color.FromArgb(100, 100, 100), // medium gray
            90F
                   );
            e.Graphics.FillRectangle(brush, this.ClientRectangle);
        }

        public LoginForm()
        {
            //Hook the paint event
            this.Paint += LoginForm_Paint;
            //Open maximized window 
            this.WindowState = FormWindowState.Maximized;
            // Create Form Title
            this.Text = "Login";
            //this.BackColor = Color.Gray;
            Label LoginLabel = new Label();
            LoginLabel.Text = "Please Login";
            LoginLabel.Location = new Point(30, 30);
            LoginLabel.AutoSize = true;
            LoginLabel.BackColor = Color.Transparent;
            LoginLabel.ForeColor = Color.Black;
            LoginLabel.Font = new("Segoe UI", 25, FontStyle.Bold);
            this.Controls.Add(LoginLabel);

            // Create Username Label
            Label usernameLabel = new Label();
            usernameLabel.Text = "Username";
            usernameLabel.Location = new Point(30, 150);
            usernameLabel.AutoSize = true;
            usernameLabel.BackColor = Color.Transparent;    
            usernameLabel.Font = new("segoe UI", 16, FontStyle.Underline);
            this.Controls.Add(usernameLabel);

            // Create TextBox
            usernameBox = new TextBox();
            usernameBox.Location = new System.Drawing.Point(30, 200);
            usernameBox.Width = 200;
            usernameBox.BackColor = Color.Gray;
            this.Controls.Add(usernameBox);

            // Create Password Label
            Label passwordLabel = new Label();
            passwordLabel.Text = "Password";
            passwordLabel.Location = new Point(30, 250);
            passwordLabel.AutoSize = true;
            passwordLabel.BackColor = Color.Transparent;    
            passwordLabel.Font = new("segoe UI", 16, FontStyle.Underline);
            this.Controls.Add(passwordLabel);

            // Create TextBox
            passwordBox = new TextBox();
            passwordBox.Location = new System.Drawing.Point(30, 300);
            passwordBox.Width = 200;
            passwordBox.BackColor = Color.Gray;
            passwordBox.PasswordChar = '*';
            this.Controls.Add(passwordBox);

            // Create Submit Button
            submitButton = new Button();
            submitButton.Text = "Submit";
            submitButton.FlatStyle = FlatStyle.Flat;
            submitButton.BackColor = Color.FromArgb(0, 112, 204);
            submitButton.ForeColor = Color.White;
            submitButton.Size = new Size(80, 30);
            submitButton.FlatAppearance.BorderSize = 0;
            submitButton.Location = new Point(
            (this.ClientSize.Width - submitButton.Width) / 2,
            (this.ClientSize.Height - submitButton.Height) / 2
                );
            submitButton.Location = new System.Drawing.Point(30, 350);
            submitButton.Click += SubmitButton_Click;
            this.Controls.Add(submitButton);

            //Create "Create Account Button"
            setupAccountButton = new Button();
            setupAccountButton.Text = "Setup Account";
            setupAccountButton.FlatStyle = FlatStyle.Flat;
            setupAccountButton.BackColor = Color.DarkBlue;
            setupAccountButton.ForeColor = Color.White;
            setupAccountButton.Size = new Size(80, 40);
            setupAccountButton.Location = new Point(
            (this.ClientSize.Width - submitButton.Width) / 2,
            (this.ClientSize.Height - submitButton.Height) / 2
                );
            setupAccountButton.FlatAppearance.BorderSize = 0;
            setupAccountButton.Location = new System.Drawing.Point(30, 400);
            setupAccountButton.Click += SubmitButton_Click;
            this.Controls.Add(setupAccountButton);

        }
                private void SubmitButton_Click(object sender, EventArgs e)
                {

                string UsernameBox = usernameBox.Text;
                string PasswordBox = passwordBox.Text;
                MessageBox.Show("You Entered Username: " + UsernameBox + "and Password: " + PasswordBox);

                Form1 mainForm = new Form1();
                mainForm.TopLevel = false;
                mainForm.FormBorderStyle = FormBorderStyle.None;
                mainForm.Dock = DockStyle.Fill;

                // Remove Login Controls and start Form1(ResolveIT dashboard)
                this.Controls.Clear();
                this.Controls.Add(mainForm);
                mainForm.Show();

                }
    
       }
	}

