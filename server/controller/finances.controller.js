const Finance = require('../models/finances.model');

exports.addFinance = async (req, res) => {
    try {
        const { amount, type, description, date } = req.body;

        // Validate required fields
        if (!amount || !type) {
            return res.status(400).json({ error: 'Amount and type are required fields' });
        }

        // Validate type
        if (!['Income', 'Expense'].includes(type)) {
            return res.status(400).json({ error: 'Type must be either Income or Expense' });
        }

        const finance = new Finance({
            amount,
            type,
            description: description || '', // Optional field
            date: date || new Date(), // Use current date if not provided
            userId: req.user.id
        });

        await finance.save();
        res.status(201).json(finance);
    } catch (error) {
        console.error('Add finance error:', error);
        res.status(500).json({ error: 'Failed to add finance record', details: error.message });
    }
};


exports.getFinances = async (req, res) => {
  try {
      const { sort, filter } = req.query;
      let query = { userId: req.user.id };

      // Add filtering options (example: filtering by type or category)
      if (filter) {
          if (filter === 'income') query.type = 'Income';
          if (filter === 'expense') query.type = 'Expense';
      }

      // Add sorting options
      let sortOption = {};
      if (sort === 'amount') sortOption.amount = 1; // Ascending by amount
      if (sort === 'recent') sortOption.createdAt = -1; // Descending by date

      const finances = await Finance.find(query).sort(sortOption);
      res.json(finances);
  } catch (error) {
      console.error('Get finances error:', error);
      res.status(500).json({ error: 'Failed to fetch finance records', details: error.message });
  }
};