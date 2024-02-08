import Onionoo from 'onionoo';
import Stats from '../schemas/statsSchema';

const onionoo = new Onionoo({
    baseUrl: 'https://onionoo.torproject.org',
    endpoints: [
        'details',
        'bandwidth',
        'uptime'
    ],
    cache: false
});


export default async function statsupdate() {
    console.log('Updating stats');
    const query = {
        contact: 'tor-relay.dev',
        limit: 1000,
        running: true,
    };

    try {
        const response = await onionoo.details?.(query);
        if (!response || !response.body) {
            throw new Error("Invalid response");
        }

        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const stats = await Stats.findOne({ date: today });

        const bps = response.body.relays.reduce((total, relay) => total + (relay.advertised_bandwidth ?? 0), 0) +
            response.body.bridges.reduce((total, bridge) => total + (bridge.advertised_bandwidth ?? 0), 0);
        const bms = Math.round((bps * 8) / 1000000);

        const top10 = response.body.relays
            .sort((a, b) => (b.advertised_bandwidth ?? 0) - (a.advertised_bandwidth ?? 0))
            .slice(0, 10)
            .map((relay) => {
                return {
                    name: relay.nickname,
                    bandwidth: Math.round((relay.advertised_bandwidth ?? 0) * 8 / 1000000)
                };
            });
        
        if (stats) {
            stats.servers = response.body.relays.length;
            stats.bridges = response.body.bridges.length;
            stats.bandwidth = bms;
            stats.top10 = top10;
            await stats.save();
        } else {
            const newStats = new Stats({
                date: today,
                servers: response.body.relays.length,
                bridges: response.body.bridges.length,
                bandwidth: bms,
                top10: top10
            });
            await newStats.save();
        }
    } catch (error) {
        console.error(`Error fetching relay info: ${error}`);
    }
}