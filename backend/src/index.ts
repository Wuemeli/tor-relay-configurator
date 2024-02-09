import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import helmet from 'helmet';
dotenv.config();

import connect from './misc/database'
import cron from './misc/cron';
import statistics from './routes/statistics';

const app = express();
const PORT = process.env.PORT || 3000;

connect();
cron();

const corsOptions = {
    origin: 'https://tor-relay.dev, http://localhost:3000',
    optionsSuccessStatus: 200
};

app.use(cors(corsOptions)); 
app.use(helmet());
app.use(express.json());

app.use('/api/statistics', statistics);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
}); 