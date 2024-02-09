import express from 'express';
import Stats from '../schemas/statsSchema';

const router = express.Router();

router.get('/', async (req, res) => {
    const today = new Date().toJSON().slice(0, 10);

    const data = await Stats.findOne({ date: today });

    res.status(200).json({
        servers: data.servers,
        bridges: data.bridges,
        bandwidth: data.bandwidth,
    });
});

router.get('/graph', async (req, res) => {
    const last7Days = new Date();
    last7Days.setDate(last7Days.getDate() - 7);

    const data = await Stats.find({ date: { $gte: last7Days } }).sort({ date: 1 });

    const servers = [] as Array<{ date: string; value: number }>;
    const bridges = [] as Array<{ date: string; value: number }>;
    const bandwidth = [] as Array<{ date: string; value: number }>;

    data.forEach((day: any) => {
        servers.push({ date: day.date.toISOString().split('T')[0], value: day.servers });
        bridges.push({ date: day.date.toISOString().split('T')[0], value: day.bridges });
        bandwidth.push({ date: day.date.toISOString().split('T')[0], value: day.bandwidth });
    });

    res.status(200).json({
        servers,
        bridges,
        bandwidth,
    });
});

router.get('/top10', async (req, res) => {
    const today = new Date().toJSON().slice(0, 10);

    const data = await Stats.findOne({ date: today });

    res.status(200).json(data.top10);
});

export default router;