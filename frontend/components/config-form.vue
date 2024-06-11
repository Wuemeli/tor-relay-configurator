<template>
    <div class="responsive-padding p-6 container mx-auto px-4 bg-background text-text">
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
                    <option value="relay">Relay</option>
                    <option value="bridge">Bridge</option>
                    <option value="exit">Exit Node</option>
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
                <input id="relayName" type="text" pattern="^[a-zA-Z0-9]{1,19}$" v-model="relayName" @input="validateRelayName($event)"
                    class="shadow appearance-none border rounded w-full py-2 px-3   text-text leading-tight focus:outline-none focus:shadow-outline"
                    placeholder="Enter Relay Nickname" required>
                <span v-if="!isRelayNameValid" class="text-red-500 text-xs">Invalid relay name. Must be 1-19 characters long and contain only letters and numbers.</span>
            </div>
            <div class="mb-4">
                <label for="contactInfo" class="block text-text text-sm font-bold mb-2">Contact Info*</label>
                <input id="contactInfo" type="email" v-model="contactInfo" @input="validateEmail($event)"
                    class="shadow appearance-none border rounded w-full py-2 px-3   text-text leading-tight focus:outline-none focus:shadow-outline"
                    placeholder="Your email address" required>
                <span v-if="!isEmailValid" class="text-red-500 text-xs">Invalid email address.</span>
            </div>
            <div class="mb-4 flex items-center">
                <input id="enable-nyx-monitoring" type="checkbox" name="enable-nyx-monitoring"
                    class="ml-4 mr-2 leading-tight" v-model="enableNyxMonitoring">
                <label for="enable-nyx-monitoring" class="text-text">Enable Nyx monitoring</label>
                <input id="blockbadips" type="checkbox" name="blockbadips"
                    class="ml-4 mr-2 leading-tight" v-if="nodeType === 'exit'" v-model="blockbadips">
                <label for="blockbadips" class="text-text" v-if="nodeType === 'exit'">Block Bad IPs</label>
            </div>
            <div class="mb-4 flex">
                <div class="flex-1 mr-2">
                    <label for="orPort" class="block text-text text-sm font-bold mb-2">ORPort*</label>
                    <input id="orPort" type="number" min="1" max="65535" v-model="orPort" @input="validatePort($event)"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="9001" required>
                    <span v-if="!isOrPortValid" class="text-red-500 text-xs">Invalid port number. Must be a number between 3000 and 65535.</span>
                </div>
                <div class="flex-1 mb-4" v-if="nodeType === 'exit'">
                    <label for="dirPort" class="block text-text text-sm font-bold mb-2">DirPort (Exit Only)</label>
                    <input id="dirPort" type="number" min="1" max="65535" v-model="dirPort" @input="validatePort($event)"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="9030">
                    <span v-if="!isDirPortValid" class="text-red-500 text-xs">Invalid port number. Must be a number between 3000 and 65535.</span>
                </div>
                <div class="flex-1 mb-4" v-if="nodeType === 'bridge'">
                    <label for="obsf4Port" class="block text-text text-sm font-bold mb-2">OBFS4 Port (Bridge Only)</label>
                    <input id="obsf4Port" type="number" min="1" max="65535" v-model="obsf4Port" @input="validatePort($event)"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="9000" required>
                    <span v-if="!isObfs4PortValid" class="text-red-500 text-xs">Invalid port number. Must be a number between 3000 and 65535.</span>
                </div>
            </div>
            <div class="mb-4">
                <label for="trafficLimit" class="block text-text text-sm font-bold mb-2">Total (Up + Down) monthly traffic
                    limit. Type nolimit for No Limit</label>
                <input id="trafficLimit" type="text" v-model="trafficLimit" @input="validateTrafficLimit($event)"
                    class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                    placeholder="e.g.  10TB">
                <span v-if="!isTrafficLimitValid" class="text-red-500 text-xs">Invalid traffic limit format. Must be a
                    number followed by TB, GB, or MB.</span>
            </div>
            <div class="mb-4 flex">
                <div class="flex-1 mr-2">
                    <label for="maxBandwidth" class="block text-text text-sm font-bold mb-2">Maximum bandwidth.
                        Type nolimit for No Limit</label>
                    <input id="maxBandwidth" type="text" v-model="maxBandwidth" @input="validateBandwidth($event)"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="Value in Mb/s">
                    <span v-if="!isMaxBandwidthValid" class="text-red-500 text-xs">Invalid bandwidth format. Must be a
                        number.</span>
                </div>
                <div class="flex-1">
                    <label for="maxBurstBandwidth" class="block text-text text-sm font-bold mb-2">Maximum burst
                        bandwidth. Type nolimit for No Limit</label>
                    <input id="maxBurstBandwidth" type="text" v-model="maxBurstBandwidth" @input="validateBandwidth($event)"
                        class="shadow appearance-none border rounded w-full py-2 px-3 text-text leading-tight focus:outline-none focus:shadow-outline"
                        placeholder="Value in Mb/s">
                    <span v-if="!isMaxBurstBandwidthValid" class="text-red-500 text-xs">Invalid burst bandwidth format. Must
                        be a number.</span>
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
            orPort: '',
            dirPort: '',
            obsf4Port: '',
            trafficLimit: 'nolimit',
            maxBandwidth: 'nolimit',
            maxBurstBandwidth: 'nolimit',
            enableNyxMonitoring: true,
            isTrafficLimitValid: true,
            isMaxBandwidthValid: true,
            isMaxBurstBandwidthValid: true,
            blockbadips: true,
            isRelayNameValid: false,
            isEmailValid: false,
            isOrPortValid: false,
            isDirPortValid: false,
            isObfs4PortValid: false
        };
    },
    methods: {
        validatePort(event) {
            const value = event.target.value;
            const regex = /^\d+$/;
            const isValid = regex.test(value) && value >= 3000 && value <= 65535;
            if (event.target.id === 'orPort') {
                this.isOrPortValid = isValid;
            } else if (event.target.id === 'dirPort') {
                this.isDirPortValid = isValid;
            } else if (event.target.id === 'obsf4Port') {
                this.isObfs4PortValid = isValid;
            }
        },
        validateEmail(event) {
            const value = event.target.value;
            const regex = /^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$/;
            this.isEmailValid = regex.test(value);
        },
        validateRelayName(event) {
            const value = event.target.value;
            const regex = /^[a-zA-Z0-9]{1,19}$/;
            this.isRelayNameValid = regex.test(value);
        },
        validateTrafficLimit(event) {
            const value = event.target.value;
            const regex = /^\s*(\d+(\.\d+)?\s*(TB|GB|MB))\s*$/i;
            this.isTrafficLimitValid = regex.test(value);
        },
        validateBandwidth(event) {
            const value = event.target.value;
            const regex = /^\s*\d+\s*$/;
            let isValid = regex.test(value) || value === 'nolimit';
            if (event.target.id === 'maxBandwidth') {
                this.isMaxBandwidthValid = isValid;
            } else if (event.target.id === 'maxBurstBandwidth') {
                this.isMaxBurstBandwidthValid = isValid;
            }
        }
    },
    computed: {
        configText() {  
            let command = `bash <(curl -sSL https://tor-relay.dev/scripts/install.sh) --os ${this.os} --node-type ${this.nodeType} --relay-name ${this.relayName} --contact-info ${this.contactInfo} --or-port ${this.orPort} --traffic-limit ${this.trafficLimit} --max-bandwidth ${this.maxBandwidth} --max-burst-bandwidth ${this.maxBurstBandwidth} --enable-nyx-monitoring ${this.enableNyxMonitoring}`;
            if (this.nodeType === 'bridge') {
                command += ` --obsf4-port ${this.obsf4Port}`;
            }
            if (this.nodeType === 'exit') {
                command += ` --block-bad-ips ${this.blockbadips}`;
                command += ` --dir-port ${this.dirPort}`;
            }
            return `${command}`;
        }
    }
};
</script>
