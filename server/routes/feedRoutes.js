const express = require('express');
const feedController = require('../controller/feed.controller');
const authenticate = require('../middleware/authenticate');

const router = express.Router();

router.post('/', authenticate, feedController.addFeed);
router.get('/', authenticate, feedController.getFeeds);
router.get('/low-stock', authenticate, feedController.getLowStockFeeds);
router.get('/:id', authenticate, feedController.getFeedById);
router.put('/:id', authenticate, feedController.updateFeed);
router.delete('/:id', authenticate, feedController.deleteFeed);
router.post('/:id/adjust-stock', authenticate, feedController.adjustStock);

module.exports = router;