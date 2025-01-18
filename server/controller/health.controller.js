const Health = require('../models/health.model');
const Cattle = require('../models/cattle.model');

exports.addHealthRecord = async (req, res) => {
    try {
        const { cattleId, type, description } = req.body;

        // Validate required fields
        if (!cattleId || !type || !description) {
            return res.status(400).json({
                error: 'Missing required fields: cattleId, type, and description are required'
            });
        }

        // Verify cattle exists and belongs to user
        const cattle = await Cattle.findOne({
            _id: cattleId,
            createdBy: req.user.id
        });

        if (!cattle) {
            return res.status(404).json({
                error: 'Cattle not found or unauthorized'
            });
        }

        // Create health record
        const healthRecord = new Health({
            ...req.body,
            createdBy: req.user.id
        });

        await healthRecord.save();
        res.status(201).json(healthRecord);
    } catch (error) {
        console.error('Add health record error:', error);
        res.status(500).json({
            error: 'Failed to add health record',
            details: error.message
        });
    }
};

exports.getHealthRecords = async (req, res) => {
    try {
        const { sort, type } = req.query;
        let query = { createdBy: req.user.id };

        // Add type filter if provided
        if (type) {
            query.type = type;
        }

        // Add sorting options
        let sortOption = {};
        if (sort === 'recent') sortOption.date = -1;
        if (sort === 'old') sortOption.date = 1;

        const healthRecords = await Health.find(query)
            .sort(sortOption)
            .populate('cattleId', 'name tag_number');

        res.json(healthRecords);
    } catch (error) {
        console.error('Get health records error:', error);
        res.status(500).json({
            error: 'Failed to fetch health records',
            details: error.message
        });
    }
};

exports.getHealthRecordsByCattle = async (req, res) => {
    try {
        const { cattleId } = req.params;

        // Verify cattle exists and belongs to user
        const cattle = await Cattle.findOne({
            _id: cattleId,
            createdBy: req.user.id
        });

        if (!cattle) {
            return res.status(404).json({
                error: 'Cattle not found or unauthorized'
            });
        }

        const healthRecords = await Health.find({
            cattleId,
            createdBy: req.user.id
        }).sort({ date: -1 });

        res.json(healthRecords);
    } catch (error) {
        console.error('Get health records by cattle error:', error);
        res.status(500).json({
            error: 'Failed to fetch health records',
            details: error.message
        });
    }
};

exports.getHealthRecordById = async (req, res) => {
    try {
        const healthRecord = await Health.findOne({
            _id: req.params.id,
            createdBy: req.user.id
        }).populate('cattleId', 'name tag_number');

        if (!healthRecord) {
            return res.status(404).json({
                error: 'Health record not found'
            });
        }

        res.json(healthRecord);
    } catch (error) {
        console.error('Get health record by ID error:', error);
        res.status(500).json({
            error: 'Failed to fetch health record',
            details: error.message
        });
    }
};

exports.updateHealthRecord = async (req, res) => {
    try {
        // Prevent updating createdBy and cattleId fields
        const { createdBy, cattleId, ...updateData } = req.body;

        const healthRecord = await Health.findOneAndUpdate(
            { _id: req.params.id, createdBy: req.user.id },
            updateData,
            { new: true, runValidators: true }
        );

        if (!healthRecord) {
            return res.status(404).json({
                error: 'Health record not found'
            });
        }

        res.json(healthRecord);
    } catch (error) {
        console.error('Update health record error:', error);
        res.status(500).json({
            error: 'Failed to update health record',
            details: error.message
        });
    }
};

exports.deleteHealthRecord = async (req, res) => {
    try {
        const healthRecord = await Health.findOneAndDelete({
            _id: req.params.id,
            createdBy: req.user.id
        });

        if (!healthRecord) {
            return res.status(404).json({
                error: 'Health record not found'
            });
        }

        res.json({
            message: 'Health record deleted successfully',
            deletedRecord: healthRecord
        });
    } catch (error) {
        console.error('Delete health record error:', error);
        res.status(500).json({
            error: 'Failed to delete health record',
            details: error.message
        });
    }
};