const Cattle = require('../models/cattle.model');

exports.addCattle = async (req, res) => {
    try {
        // Validate required fields
        const { name, breed, gender, tag_number } = req.body;
        if (!name || !breed || !gender || !tag_number) {
            return res.status(400).json({ 
                error: 'Missing required fields: name, breed, gender, and tag_number are required' 
            });
        }

        // Validate gender enum
        if (!['Male', 'Female'].includes(gender)) {
            return res.status(400).json({ 
                error: 'Gender must be either Male or Female' 
            });
        }

        // Check for duplicate tag number
        const existingCattle = await Cattle.findOne({ 
            tag_number, 
            createdBy: req.user.id 
        });
        if (existingCattle) {
            return res.status(400).json({ 
                error: 'Tag number already exists' 
            });
        }

        const cattle = new Cattle({ 
            ...req.body, 
            createdBy: req.user.id 
        });
        await cattle.save();
        res.status(201).json(cattle);
    } catch (error) {
        console.error('Add cattle error:', error);
        res.status(500).json({ 
            error: 'Failed to add cattle', 
            details: error.message 
        });
    }
};

exports.getCattle = async (req, res) => {
    try {
        const { sort, filter } = req.query;
        let query = { createdBy: req.user.id };

        // Add filtering options
        if (filter) {
            if (filter === 'male') query.gender = 'Male';
            if (filter === 'female') query.gender = 'Female';
        }

        // Add sorting options
        let sortOption = {};
        if (sort === 'age') sortOption.age = 1;
        if (sort === 'recent') sortOption.createdAt = -1;

        const cattle = await Cattle.find(query)
            .sort(sortOption)
            .select('-healthRecords'); // Exclude health records for list view

        res.json(cattle);
    } catch (error) {
        console.error('Get cattle error:', error);
        res.status(500).json({ 
            error: 'Failed to fetch cattle', 
            details: error.message 
        });
    }
};

exports.getCattleById = async (req, res) => {
    try {
        const cattle = await Cattle.findOne({ 
            _id: req.params.id, 
            createdBy: req.user.id 
        });
        
        if (!cattle) {
            return res.status(404).json({ error: 'Cattle not found' });
        }
        
        res.json(cattle);
    } catch (error) {
        console.error('Get cattle by ID error:', error);
        res.status(500).json({ 
            error: 'Failed to fetch cattle details', 
            details: error.message 
        });
    }
};

exports.updateCattle = async (req, res) => {
    try {
        // Prevent updating createdBy field
        const { createdBy, ...updateData } = req.body;

        // Validate gender if it's being updated
        if (updateData.gender && !['Male', 'Female'].includes(updateData.gender)) {
            return res.status(400).json({ 
                error: 'Gender must be either Male or Female' 
            });
        }

        // Check for duplicate tag number if updating
        if (updateData.tag_number) {
            const existingCattle = await Cattle.findOne({
                tag_number: updateData.tag_number,
                createdBy: req.user.id,
                _id: { $ne: req.params.id }
            });
            if (existingCattle) {
                return res.status(400).json({ 
                    error: 'Tag number already exists' 
                });
            }
        }

        const cattle = await Cattle.findOneAndUpdate(
            { _id: req.params.id, createdBy: req.user.id },
            updateData,
            { new: true, runValidators: true }
        );

        if (!cattle) {
            return res.status(404).json({ error: 'Cattle not found' });
        }

        res.json(cattle);
    } catch (error) {
        console.error('Update cattle error:', error);
        res.status(500).json({ 
            error: 'Failed to update cattle', 
            details: error.message 
        });
    }
};

exports.addHealthRecord = async (req, res) => {
    try {
        const { notes } = req.body;
        if (!notes) {
            return res.status(400).json({ 
                error: 'Notes are required for health record' 
            });
        }

        const cattle = await Cattle.findOneAndUpdate(
            { _id: req.params.id, createdBy: req.user.id },
            { 
                $push: { 
                    healthRecords: { notes, date: new Date() } 
                } 
            },
            { new: true }
        );

        if (!cattle) {
            return res.status(404).json({ error: 'Cattle not found' });
        }

        res.json(cattle);
    } catch (error) {
        console.error('Add health record error:', error);
        res.status(500).json({ 
            error: 'Failed to add health record', 
            details: error.message 
        });
    }
};

exports.deleteCattle = async (req, res) => {
    try {
        const cattle = await Cattle.findOneAndDelete({
            _id: req.params.id,
            createdBy: req.user.id,
        });

        if (!cattle) {
            return res.status(404).json({ error: 'Cattle not found' });
        }

        res.json({ 
            message: 'Cattle deleted successfully',
            deletedCattle: cattle
        });
    } catch (error) {
        console.error('Delete cattle error:', error);
        res.status(500).json({ 
            error: 'Failed to delete cattle', 
            details: error.message 
        });
    }
};