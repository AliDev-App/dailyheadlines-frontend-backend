const express = require('express');
const sql = require('mssql');
const bcrypt = require('bcryptjs');
const cors = require('cors');   
require('dotenv').config();

const app = express();
app.use(cors()); 
app.use(express.json());

// SQL Server configuration
console.log('🧪 ENV:', process.env.DB_SERVER);
const [serverHost, instanceName] = "DESKTOP-KU2I6OA\\SQLEXPRESS".split('\\');


const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: serverHost,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT),
  options: {
    encrypt: false,
    trustServerCertificate: true,
    instanceName: instanceName // this is the key fix ✅
  }
};




// POST /add-news — domain side
app.post('/add-news', async (req, res) => {
    const { title, description, imageUrl, author } = req.body;
    console.log("🔔 Received POST /add-news", req.body);
    try {
        await sql.connect(config);
        await sql.query`EXEC InsertNews @Title=${title}, @Description=${description}, @ImageUrl=${imageUrl}, @Author=${author}`;
        res.status(200).json({ message: '✅ News inserted successfully' });
    } catch (err) {
        console.error('Insert Error:', err);
        res.status(500).json({ error: 'Insert failed' });
    }
});

// GET /get-news — user side
app.get('/get-news', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query(`EXEC GetAllNews`); // This line calls your SP
        const data = result.recordset; // This gets the actual data rows
        res.status(200).json(data);
    } catch (err) {
        console.error('Fetch Error:', err);
        res.status(500).json({ error: 'Fetch failed' });
    }
});



app.delete('/delete-news/:id', async (req, res) => {
    const { id } = req.params;
    // Added validation for the ID
    if (isNaN(id)) {
        return res.status(400).json({ error: 'Invalid ID provided. ID must be a number.' });
    }
    console.log("🗑️ Deleting news with ID:", id);

    try {
        const pool = await sql.connect(config);
        const result = await pool.request()
            .input('Id', sql.Int, parseInt(id)) // Explicitly parse to int and set SQL type
            .execute('DeleteNews');
            console.log('🧾 rowsAffected:', result.rowsAffected);

        if (result.rowsAffected && result.rowsAffected[0] > 0) { // Check rowsAffected correctly
           res.status(200).json({ message: '✅ News deleted successfully' });
        } 
            // If we get here, no rows were deleted
        return res.status(404).json({ error: '❌ News item not found' });

    } catch (err) {
        console.error('❌ Delete Error:', err);
        res.status(500).json({ error: 'Delete failed', details: err.message });
    } 
});



app.post('/signup', async (req, res) => {
  const { name, email, password, role } = req.body;

  // Log incoming values
  console.log('📥 Incoming signup:', { name, email, password, role });

  // Validate input
  if (!name || !email || !password || !role) {
    return res.status(400).json({ error: '❌ Missing one or more required fields (name, email, password, role)' });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('Name', sql.NVarChar, name)
      .input('Email', sql.NVarChar, email)
      .input('Password', sql.NVarChar, hashedPassword)
      .input('Role', sql.NVarChar, role)
      .execute('SignupUser');

    res.json({ message: result.recordset[0]?.Message });
  } catch (err) {
    console.error('❌ Signup Error:', err);
    res.status(500).json({ error: err.message });
  }
});

  // ===================== LOGIN =====================
  app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('Email', sql.NVarChar, email)
      .execute('GetUserByEmail');

    const user = result.recordset[0];

    // Check if user exists and has a password
    if (!user || !user.Password) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Compare password using bcrypt
    const passwordMatch = await bcrypt.compare(password, user.Password);

    if (!passwordMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Success: return user data
    res.json({
      id: user.Id,
      name: user.Name,
      email: user.Email,
      role: user.Role,
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


  // ===================== FORGOT / RESET PASSWORD =====================
  app.post('/reset-password', async (req, res) => {
    const { email, newPassword } = req.body;
    const hashedNewPassword = await bcrypt.hash(newPassword, 10);

    try {
      const pool = await sql.connect(config);  
      const result = await pool.request()
        .input('Email', sql.NVarChar, email)
        .input('NewPassword', sql.NVarChar, hashedNewPassword)
        .execute('ResetPassword');

      res.json({ message: result.recordset[0]?.Message });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });



app.post('/get-user-by-email', async (req, res) => {
  const { email } = req.body;

  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('Email', sql.NVarChar, email)
      .execute('GetUserByEmail');

    if (result.recordset.length > 0) {
      res.status(200).json(result.recordset[0]);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});














































app.use((req, res) => {
    console.log('❗ Unmatched Route:', req.method, req.url);
    res.status(404).send('Not Found');
});


app.listen(3000, () => {
    console.log('🚀 API running at http://localhost:3000');
});
