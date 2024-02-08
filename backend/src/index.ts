import express from 'express';
import cors from 'cors';
import routes from './routes';
import connect from './misc/database'
import dotenv from 'dotenv';
import cron from './misc/cron';
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

connect();
cron();
app.use(cors());
app.use(express.json());
app.use(routes);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});