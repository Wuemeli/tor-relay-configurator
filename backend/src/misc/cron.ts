import nodecron from 'node-cron';
import statsupdate from './statsupdater';

export default async function startCron() {
    await statsupdate();
    nodecron.schedule('0 * * * *', async () => {
        await statsupdate();
    });
}
