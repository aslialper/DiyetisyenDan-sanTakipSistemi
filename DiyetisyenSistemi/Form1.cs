using System;
using System.Data;
using System.Windows.Forms;
using MySql.Data.MySqlClient;

namespace DiyetisyenSistemi
{
    public partial class Form1 : Form
    {
        string connectionString = "Server=localhost;Database=diyetisyen_takip;Uid=root;Pwd=Berrin.01;";

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            TabloyuYenile();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    MySqlCommand cmd = new MySqlCommand("sp_RandevuEkle", conn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("dyt_id", textBox1.Text);
                    cmd.Parameters.AddWithValue("dns_id", textBox2.Text);
                    cmd.Parameters.AddWithValue("tarih", dateTimePicker1.Value);

                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Randevu başarıyla eklendi!", "Başarılı", MessageBoxButtons.OK, MessageBoxIcon.Information);

                    TabloyuYenile();
                }
                catch (MySqlException ex)
                {
                    MessageBox.Show(ex.Message, "İşlem Başarısız", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void TabloyuYenile()
        {
            using (MySqlConnection conn = new MySqlConnection(connectionString))
            {
                try
                {
                    conn.Open();
                    MySqlCommand cmd = new MySqlCommand("sp_RandevuListe", conn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    MySqlDataAdapter da = new MySqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    dataGridView1.DataSource = dt;
                }
                catch
                {
                }
            }
        }

        private void label1_Click(object sender, EventArgs e)
        {
        }

        private void label2_Click(object sender, EventArgs e)
        {
        }
    }
}