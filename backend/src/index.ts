import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
dotenv.config();

import connect from './misc/database'
import cron from './misc/cron';
import statistics from './routes/statistics';

const app = express();
const PORT = process.env.PORT || 3000;

connect();
cron();

app.use(cors());
app.use(express.json());

app.use('/api/statistics', statistics);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});