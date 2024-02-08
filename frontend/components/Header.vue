<template>
    <header class="text-charcoal p-4">
        <div class="container mx-auto flex justify-between items-center">
            <div>
                <h1 class="text-4xl font-bold">Tor Relay Configurator</h1>
                <p class="mt-2 text-sm">Get your own Tor Relay up and running in seconds.</p>
            </div>
            <div class="border border-gray-300 p-4 rounded">
                <div class="grid grid-cols-3 gap-4">
                    <div class="flex flex-col items-center">
                        <span class="font-gray-700 font-semibold text-xs">Servers:</span>
                        <span class="ml-2 text-3xl">{{ stats.servers }}</span>
                    </div>
                    <div class="flex flex-col items-center">
                        <span class="font-semibold text-xs">Bridges:</span>
                        <span class="ml-2 text-3xl">{{ stats.bridges }}</span>
                    </div>
                    <div class="flex flex-col items-center">
                        <span class="font-semibold text-xs">Bandwidth:</span>
                        <span class="ml-2 text-3xl">{{ stats.bandwidth }}Mb/s</span>
                    </div>
                </div>
            </div>
        </div>
    </header>
</template>

<script>
export default {
    data() {
        return {
            stats: {}
        };
    },
    mounted() {
        this.getStats();
    },
    methods: {
        async getStats() {
            const response = await fetch('https://api.tor-relay.dev/api/statistics');
            this.stats = await response.json();
        }
    }
}
</script>