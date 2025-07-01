const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const productRoute = require('./src/routes/productRoute');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/product', productRoute);

// Error handling middleware (corrected)
app.use((err, res) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something broke!', error: err.message });
});

// Database connection
const db = require('./src/config/db');

db.query('SELECT 1')
  .then(() => {
    console.log('Database connection successful');
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('Database connection failed:', err);
    process.exit(1);
  });

module.exports = app;
