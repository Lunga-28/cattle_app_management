const express = require('express');
const Cattle = require('../models/Cattle');
const router = express.Router();
const authenticate = require('../middleware/authenticate');

// Add new cattle
router.post('/', authenticate, async (req, res) => {
  try {
    const cattle = new Cattle({ ...req.body, createdBy: req.user.id });
    await cattle.save();
    res.status(201).json(cattle);
  } catch (error) {
    res.status(500).json({ error: 'Failed to add cattle' });
  }
});

// Get all cattle for the user
router.get('/', authenticate, async (req, res) => {
  try {
    const cattle = await Cattle.find({ createdBy: req.user.id });
    res.json(cattle);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch cattle' });
  }
});

// Update cattle
router.put('/:id', authenticate, async (req, res) => {
  try {
    const cattle = await Cattle.findOneAndUpdate(
      { _id: req.params.id, createdBy: req.user.id },
      req.body,
      { new: true }
    );
    if (!cattle) return res.status(404).json({ error: 'Cattle not found' });

    res.json(cattle);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update cattle' });
  }
});

// Delete cattle
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const cattle = await Cattle.findOneAndDelete({
      _id: req.params.id,
      createdBy: req.user.id,
    });
    if (!cattle) return res.status(404).json({ error: 'Cattle not found' });

    res.json({ message: 'Cattle deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete cattle' });
  }
});

module.exports = router;
