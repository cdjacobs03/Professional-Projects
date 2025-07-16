using Newtonsoft.Json;
using System.Drawing.Drawing2D;
using System.Net;
using System.Net.Http;

namespace Ticket_Dashboard
{
    public partial class Form1 : Form
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

        public Form1()
        {

            //Set form title and color, then create main Label
            this.Text = "Company Dashboard";
            this.Paint += LoginForm_Paint;
            Label welcomeCompanyLabel = new Label();
            welcomeCompanyLabel.Text = "Welcome To ResolveIT Dashboard";
            //welcomeCompanyLabel.Location = new Point((this.ClientSize.Width - welcomeCompanyLabel.Width), 50);
            welcomeCompanyLabel.AutoSize = true;
            welcomeCompanyLabel.Font = new Font("Segoe UI", 25, FontStyle.Bold);
            welcomeCompanyLabel.BackColor = Color.Transparent;
            welcomeCompanyLabel.Location = new Point(700, 50);
            this.Controls.Add(welcomeCompanyLabel);


            // Create MyList Button
            Button myListButton = new Button();
            myListButton.Text = "My List";
            myListButton.FlatStyle = FlatStyle.Flat;
            //myListButton.BackColor = Color.Transparent;
            myListButton.ForeColor = Color.Black;
            myListButton.BackColor = Color.Gray;
            myListButton.Location = new System.Drawing.Point(30, 150);
            myListButton.Click += SubmitButton_Click;
            this.Controls.Add(myListButton);



            TextBox CalebTickets = new TextBox();
            CalebTickets.BackColor = Color.Gray;
            CalebTickets.ForeColor = Color.Black;
            CalebTickets.Location = new System.Drawing.Point(150, 200);
            CalebTickets.ReadOnly = true;
            CalebTickets.Size = new Size(100, 150);
            this.Controls.Add(CalebTickets);
            getTickets(CalebTickets);

        }
        private void SubmitButton_Click(object sender, EventArgs e)
        {

            Form2 mainForm = new Form2();
            mainForm.TopLevel = false;
            mainForm.FormBorderStyle = FormBorderStyle.None;
            mainForm.Dock = DockStyle.Fill;

            // Remove Login Controls and start Form1(ResolveIT dashboard)
            this.Controls.Clear();
            this.Controls.Add(mainForm);
            mainForm.Show();

        }
        //Grab Tickets from Syncro
        private async void getTickets(TextBox ticketLabel)
        {
            //Ensure TLS 1.2 is enabled 
            System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Add("Authorization", "Bearer T0941d676291b93fcb-c17e8636ee6a03372e86ea04be72ce70");
                                              

                //Call Syncro API using GET
                HttpResponseMessage response = await client.GetAsync("https://resolveittech.syncromsp.com/api/v1/tickets/96025777");

                if (response.IsSuccessStatusCode)
                {
                    string json = await response.Content.ReadAsStringAsync();

                    // Parse the JSON and update UI
                    dynamic ticketData = JsonConvert.DeserializeObject(json); // requires Newtonsoft.Json
                    string ticketSubject = ticketData.subject; // adjust key as needed

                    // Update form control
                    ticketLabel.Text = ticketSubject;
                }
                else
                {
                    string responseBody = await response.Content.ReadAsStringAsync();
                    ticketLabel.Text = $"Failed to load ticket: {response.StatusCode}\n{responseBody}"; ;
                }
            }    
        }

    }
}
