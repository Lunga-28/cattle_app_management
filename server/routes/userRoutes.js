const express = require('express');
const { getUserProfile, updateProfile, changePassword } = require('../controller/user.controller.js');
const authenticate = require('../middleware/authenticate.js');

const router = express.Router();

// All routes require authentication
router.use(authenticate);

router.get('/profile', getUserProfile);
router.put('/profile', updateProfile);
router.put('/change-password', changePassword);

module.exports = router;