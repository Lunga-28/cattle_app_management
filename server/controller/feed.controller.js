const Feed = require('../models/feed.model');

exports.addFeed = async (req, res) => {
    try {
        const { name, type, quantity, unit, cost, stockAlert } = req.body;

        // Validate required fields
        if (!name || !type || !quantity || !unit || !cost || !stockAlert) {
            return res.status(400).json({
                error: 'Missing required fields: name, type, quantity, unit, cost, and stockAlert are required'
            });
        }

        // Create new feed record
        const feed = new Feed({
            ...req.body,
            createdBy: req.user.id
        });

        await feed.save();
        res.status(201).json(feed);
    } catch (error) {
        console.error('Add feed error:', error);
        res.status(500).json({
            error: 'Failed to add feed',
            details: error.message
        });
    }
};

exports.getFeeds = async (req, res) => {
    try {
        const { sort, type } = req.query;
        let query = { createdBy: req.user.id };

        // Add type filter if provided
        if (type) {
            query.type = type;
        }

        // Add sorting options
        let sortOption = {};
        if (sort === 'quantity') sortOption.quantity = 1;
        if (sort === 'expiry') sortOption.expiryDate = 1;
        if (sort === 'recent') sortOption.createdAt = -1;

        const feeds = await Feed.find(query)
            .sort(sortOption);

        res.json(feeds);
    } catch (error) {
        console.error('Get feeds error:', error);
        res.status(500).json({
            error: 'Failed to fetch feeds',
            details: error.message
        });
    }
};

exports.getLowStockFeeds = async (req, res) => {
    try {
        const lowStockFeeds = await Feed.find({
            createdBy: req.user.id,
            quantity: { $lte: { $ref: 'stockAlert' } }
        });

        res.json(lowStockFeeds);
    } catch (error) {
        console.error('Get low stock feeds error:', error);
        res.status(500).json({
            error: 'Failed to fetch low stock feeds',
            details: error.message
        });
    }
};

exports.getFeedById = async (req, res) => {
    try {
        const feed = await Feed.findOne({
            _id: req.params.id,
            createdBy: req.user.id
        });

        if (!feed) {
            return res.status(404).json({
                error: 'Feed not found'
            });
        }

        res.json(feed);
    } catch (error) {
        console.error('Get feed by ID error:', error);
        res.status(500).json({
            error: 'Failed to fetch feed',
            details: error.message
        });
    }
};

exports.updateFeed = async (req, res) => {
    try {
        // Prevent updating createdBy field
        const { createdBy, ...updateData } = req.body;

        const feed = await Feed.findOneAndUpdate(
            { _id: req.params.id, createdBy: req.user.id },
            updateData,
            { new: true, runValidators: true }
        );

        if (!feed) {
            return res.status(404).json({
                error: 'Feed not found'
            });
        }

        res.json(feed);
    } catch (error) {
        console.error('Update feed error:', error);
        res.status(500).json({
            error: 'Failed to update feed',
            details: error.message
        });
    }
};

exports.deleteFeed = async (req, res) => {
    try {
        const feed = await Feed.findOneAndDelete({
            _id: req.params.id,
            createdBy: req.user.id
        });

        if (!feed) {
            return res.status(404).json({
                error: 'Feed not found'
            });
        }

        res.json({
            message: 'Feed deleted successfully',
            deletedFeed: feed
        });
    } catch (error) {
        console.error('Delete feed error:', error);
        res.status(500).json({
            error: 'Failed to delete feed',
            details: error.message
        });
    }
};

exports.adjustStock = async (req, res) => {
    try {
        const { adjustment, operation } = req.body;

        if (!adjustment || !operation) {
            return res.status(400).json({
                error: 'Adjustment amount and operation type (add/subtract) are required'
            });
        }

        const feed = await Feed.findOne({
            _id: req.params.id,
            createdBy: req.user.id
        });

        if (!feed) {
            return res.status(404).json({
                error: 'Feed not found'
            });
        }

        // Calculate new quantity
        let newQuantity;
        if (operation === 'add') {
            newQuantity = feed.quantity + adjustment;
        } else if (operation === 'subtract') {
            newQuantity = feed.quantity - adjustment;
            if (newQuantity < 0) {
                return res.status(400).json({
                    error: 'Insufficient stock for this operation'
                });
            }
        } else {
            return res.status(400).json({
                error: 'Invalid operation. Use "add" or "subtract"'
            });
        }

        // Update feed quantity
        feed.quantity = newQuantity;
        await feed.save();

        res.json({
            message: 'Stock adjusted successfully',
            feed
        });
    } catch (error) {
        console.error('Adjust stock error:', error);
        res.status(500).json({
            error: 'Failed to adjust stock',
            details: error.message
        });
    }
};