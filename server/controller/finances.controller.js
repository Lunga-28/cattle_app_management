const Finance = require('../models/finances.model');

exports.addFinance = async (req, res) => {
  try {
    const finance = new Finance({ ...req.body, userId: req.user.id });
    await finance.save();
    res.status(201).json(finance);
  } catch (error) {
    res.status(500).json({ error: 'Failed to add finance record' });
  }
};

exports.getFinances = async (req, res) => {
  try {
    const finances = await Finance.find({ userId: req.user.id });
    res.json(finances);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch finance records' });
  }
};
