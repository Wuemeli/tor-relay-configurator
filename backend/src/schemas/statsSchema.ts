const mongoose = require('mongoose');

const statsSchema = new mongoose.Schema({
    date: { type: Date, required: true },
    servers: { type: Number, required: true },
    bridges: { type: Number, required: true },
    bandwidth: { type: Number, required: true },
    top10: { type: Array, required: true }
});

export default mongoose.model('Stats', statsSchema);