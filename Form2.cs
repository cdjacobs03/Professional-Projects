using System.Drawing.Drawing2D;

namespace Ticket_Dashboard
{

    public partial class Form2 : Form
     {

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
        public Form2()
        {

            this.Paint += LoginForm_Paint;
            this.Text = "My Dashboard";
            Label welcomeMyLabel = new Label();
            welcomeMyLabel.Text = "Welcome to your Dashboard";
            welcomeMyLabel.Location = new Point(30, 30);
            welcomeMyLabel.AutoSize = true;
            welcomeMyLabel.BackColor = Color.Transparent;
            welcomeMyLabel.Font = new Font("Segoe UI", 25, FontStyle.Bold);
            this.Controls.Add(welcomeMyLabel);

        }
    }
}