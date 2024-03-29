<template>
    <div class="responsive-padding flex justify-center space-x-4">
        <div class="border border-gray-400 p-4 rounded">
            <h2 class="text-xl font-bold mb-4">Total Relays/Bridges</h2>
            <client-only>
                <apexchart :key="series1" height="400" width="180%" :options="options1" :series="series1" type="line">
                </apexchart>
            </client-only>
        </div>
        <div class="border border-gray-400 p-4 rounded">
            <h2 class="text-xl font-bold mb-4">Total Bandwidth</h2>
            <client-only>
                <apexchart :key="series2" height="400" width="180%" :options="options2" :series="series2" type="line">
                </apexchart>
            </client-only>
        </div>
        <div class="border border-gray-400 p-4 rounded">
            <leaderboard />
        </div>
    </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';

const options1 = ref({
    chart: {
        type: "line",
    },
    theme: {
        mode: 'dark'
    },
    plotOptions: {
        bar: {
            borderRadius: 10,
            borderRadiusApplication: "around",
        },
    },
    xaxis: {
        type: 'datetime',
        categories: [],
        labels: {
            show: true,
            rotate: -45,
            rotateAlways: false,
            hideOverlappingLabels: true,
            style: {
                colors: ['#ffffff'],
                fontSize: '12px',
                fontFamily: 'Helvetica, Arial, sans-serif',
                fontWeight: 400,
                cssClass: 'apexcharts-xaxis-label',
            },
            datetimeUTC: false,
            formatter: function (value: string, timestamp: string) {
                return new Date(timestamp).toLocaleDateString();
            },
        },
        min: null,
        max: null,
    },
});

const options2 = ref({
    chart: {
        type: "line",
    },
    theme: {
        mode: 'dark'
    },
    plotOptions: {
        bar: {
            borderRadius: 10,
            borderRadiusApplication: "around",
        },
    },
    xaxis: {
        type: 'datetime',
        categories: [],
        labels: {
            show: true,
            rotate: -45,
            rotateAlways: false,
            hideOverlappingLabels: true,
            style: {
                colors: ['#ffffff'],
                fontSize: '12px',
                fontFamily: 'Helvetica, Arial, sans-serif',
                fontWeight: 400,
                cssClass: 'apexcharts-xaxis-label',
            },
            datetimeUTC: false,
            formatter: function (value: string, timestamp: string) {
                return new Date(timestamp).toLocaleDateString();
            },
        },
        min: null,
        max: null,
    },
});

const series1 = ref([
    {
        name: "Servers",
        data: [],
    },
    {
        name: "Bridges",
        data: [],
    },
]);

const series2 = ref([
    {
        name: "Bandwidth",
        data: [],
    },
]);

onMounted(async () => {
    try {
        const response = await fetch('https://api.tor-relay.dev/api/statistics/graph');
        const data = await response.json();
        series1.value[0].data = data.servers.map(item => [new Date(item.date).getTime(), item.value]);
        series1.value[1].data = data.bridges.map(item => [new Date(item.date).getTime(), item.value]);
        series2.value[0].data = data.bandwidth.map(item => [new Date(item.date).getTime(), item.value]);

        options1.value.xaxis.categories = data.servers.map(item => new Date(item.date).toISOString());
        options2.value.xaxis.categories = data.servers.map(item => new Date(item.date).toISOString());
    } catch (error) {
        console.error(error);
    }
});
</script>