<template>
    <div class="leaderboard bg-background p-6">
        <h2 class="text-xl font-bold mb-4">Top 10 Relays</h2>
        <ul v-if="leaderboardData.length > 0" class="list-none">
            <li v-for="(entry, index) in leaderboardData.slice(0, 3)" :key="index" class="mb-2">
                <span class="font-semibold">{{ index === 0 ? '1. 🥇' : index === 1 ? '2. 🥈' : index === 2 ? '3. 🥉' : index + 1
                }}</span>
                <span class="ml-2">{{ entry.name }}</span>
                <span class="ml-2 text-gray-500">({{ entry.bandwidth
                }}Mb/s)</span>
            </li>
            <li v-for="(entry, index) in leaderboardData.slice(3)" :key="index + 3" class="mb-2">
                <span class="font-semibold">{{ index + 4 }}.</span>
                <span class="ml-2">{{ entry.name }}</span>
                <span class="ml-2 text-gray-500">({{ entry.bandwidth
                }}Mb/s)</span>
            </li>
        </ul>
        <p v-else class="text-center text-gray-500">Loading...</p>
    </div>
</template>

<script>
export default {
    data() {
        return {
            leaderboardData: [],
        };
    },
    mounted() {
        this.fetchLeaderboardData();
    },
    methods: {
        async fetchLeaderboardData() {
            try {
                const response = await fetch('http://api.tor-relay.dev/api/statistics/top10');
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                this.leaderboardData = await response.json();
            } catch (error) {
                console.error('There has been a problem with your fetch operation:', error);
            }
        },
    },
};
</script>

<style scoped>/* Add your custom styles here if needed */</style>