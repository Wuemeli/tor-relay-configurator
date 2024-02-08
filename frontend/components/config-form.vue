<template>
    <div class="p-6 container mx-auto px-4 bg-background text-text">
        <h1 class="text-4xl font-bold">Tor Relay Configurator</h1>
        <p class="mt-2 text-text">Be sure to have curl and sudo installed on your system.</p>
        <br>
        <form>
            <div class="mb-4">
                <label for="nodeType" class="block text-text text-sm font-bold mb-2">Tor node type*</label>
                <select id="nodeType" name="nodeType" v-model="nodeType"
                    class="shadow appearance-none border rounded w-full py-2 px-3   text-text leading-tight focus:outline-none focus:shadow-outline"
                    required>
                    <option value="">Select Tor Node Type</option>
                    <option value="relay">Relay (Default)</option>
                    <option value="bridge">Bridge</option>
                    <option value="exit">Exit Node (Following ReducedExitPolicy)</option>
                </select>
                <label for="os" class="block text-text text-sm font-bold mb-2 mt-4">Operating System*</label>
                <select id="os" name="os" v-model="os"
                    class="shadow appearance-none border rounded w-full py-2 px-3   text-text leading-tight focus:outline-none focus:shadow-outline"
                    required>
                    <option value="">Select Operating System</option>
                    <option value="debian">Debian</option>
                    <option value="ubuntu">Ubuntu</option>
                    <option value="centos">CentOS</option>
                    <option value="arch">Arch Linux</option>
                </select>
            </div>
            <div class="mb-4">
                <label for="relayName" class="block text-text text-sm font-bold mb-2">Relay Name*</label>
                <input id="relayName" type="text" pattern="^[a-zA-Z0-9]{1,19}$" v-model="relayName"
                    class="shadow appearance-none border rounded w-full py-2 px-3   text-text leading-tight focus:outline-none focus:shadow-outline"
                    placeholder="Enter Relay Nickname" required>
            </div>
            <div class="mb-4">
                <label for="contactInfo" class="block text-text text-sm font-bold mb-2">Contact Info*</label>
                <input id="contactInfo" type="email" v-model="contactInfo"
                    class="shadow appearance-none border rounded w-full py-2 px-3   text-text leading-tight focus:outline-none focus:shadow-outline"
                    placeholder="Your email address" required>
            </div>
            <div class="mb-4 flex items-center">
                <input id="enable-nyx-monitoring" type="checkbox" name="enable-nyx-monitoring"
                    class="ml-4 mr-2 leading-tight" v-model="enableNyxMonitoring">
                <label for="enable-nyx-monitoring" class="text-text">Enable Nyx monitoring</label>
                <input id="enableIPv6" type="checkbox" name="enableIPv6" class="ml-4 mr-2 leading-tight"
                    v-model="enableIPv6">
                <label for="enableIPv6" class="text-text">Enable IPv6 support</label>
            </div>
            <div class="mb-4 flex">
                <div class="flex-1 mr-2">
                    <label for="orPort" class="block text-text text-sm font-bold mb-2">ORPort*</label>
                    <input id="orPort" type="number" min="1" max="65535" v-model="orPort"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="9001" required>
                </div>
                <div class="flex-1">
                    <label for="dirPort" class="block text-text text-sm font-bold mb-2">DirPort</label>
                    <input id="dirPort" type="number" min="1" max="65535" v-model="dirPort"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="9030">
                </div>
            </div>
            <div class="mb-4">
                <label for="trafficLimit" class="block text-text text-sm font-bold mb-2">Total (Up + Down) monthly traffic
                    limit (empty for no limit)</label>
                <input id="trafficLimit" type="text" v-model="trafficLimit" @input="validateTrafficLimit($event)"
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                    placeholder="e.g.  10TB">
                <span v-if="!isTrafficLimitValid" class="text-red-500 text-xs">Invalid traffic limit format. Must be a
                    number followed by TB, GB, or MB.</span>
            </div>
            <div class="mb-4 flex">
                <div class="flex-1 mr-2">
                    <label for="maxBandwidth" class="block text-text text-sm font-bold mb-2">Maximum bandwidth (empty for no
                        limit)</label>
                    <input id="maxBandwidth" type="text" v-model="maxBandwidth"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="Value in Mb/s">
                </div>
                <div class="flex-1">
                    <label for="maxBurstBandwidth" class="block text-text text-sm font-bold mb-2">Maximum burst
                        bandwidth (empty for no limit)</label>
                    <input id="maxBurstBandwidth" type="text" v-model="maxBurstBandwidth"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="Value in Mb/s">
                </div>
            </div>
        </form>


        <h2 class="p-2 text-2xl font-bold mb-4 justify-center text-center">Installation Command</h2>
        <div class="mt-4 flex items-center justify-between">
            <div class="bg-background p-4 rounded border">
                <pre id="configFile" class="text-text">{{ configText }}</pre>
            </div>
        </div>

        <div class="mt-4 text-center text-gray-500 text-xs">
            We do not take any responsibility for the use of this tool.
            By using our script your relay nickname and bandwidth will be counted in the global statistics panel on the top
            right. This is anonymous. We only save Bandwidth and Nickname. We do not save any other information.
        </div>

    </div>
</template>
    
<script>
export default {
    data() {
        return {
            os: '',
            nodeType: '',
            relayName: '',
            contactInfo: '',
            enableIPv6: false,
            orPort: '',
            dirPort: '',
            trafficLimit: '',
            maxBandwidth: '',
            maxBurstBandwidth: '',
            enableNyxMonitoring: false,
            isTrafficLimitValid: false
        };
    },
    methods: {
        validateTrafficLimit(event) {
            const value = event.target.value;
            const regex = /^\s*(\d+(\.\d+)?\s*(TB|GB|MB))\s*$/i;
            this.isTrafficLimitValid = regex.test(value);
        }
    },
    computed: {
        configText() {
            const command = `curl -sSL https://tor-relay.dev/scripts/install.sh | bash -s -- --os ${this.os} --node-type ${this.nodeType} --relay-name ${this.relayName} --contact-info ${this.contactInfo} --enable-ipv6 ${this.enableIPv6} --or-port ${this.orPort} --dir-port ${this.dirPort} --traffic-limit ${this.trafficLimit} --max-bandwidth ${this.maxBandwidth} --max-burst-bandwidth ${this.maxBurstBandwidth} --enable-nyx-monitoring ${this.enableNyxMonitoring}`;
            return `${command}`;
        }
    }
};
</script>
