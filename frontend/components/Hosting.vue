<template>
    <div class="responsive-padding p-6">
        <h2 class="text-2xl font-bold mb-4">Hosting Options</h2>
        <p class="mb-4">
            You can run your Tor relay on every supported Linux machine that you have SSH access to, be it in your home, a
            virtual server, or a dedicated server. But not every hoster or ISP allows Tor relays in their network.
        </p>
        <table class="table-fixed w-full">
            <thead>
                <tr>
                    <th class="border px-4 py-2">Name</th>
                    <th class="border px-4 py-2">Server Location</th>
                    <th class="border px-4 py-2">Middle Node (Relay)</th>
                    <th class="border px-4 py-2">Exit Node</th>
                    <th class="border px-4 py-2">Bitcoin</th>
                    <th class="border px-4 py-2">Link</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td class="border px-4 py-2">Linevast</td>
                    <td class="border px-4 py-2">Germany</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">No</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2"><a href="https://linevast.de/" class="text-blue-500 hover:underline" target="_blank">View Page</a></td>
                </tr>
                <tr>
                    <td class="border px-4 py-2">Flokinet</td>
                    <td class="border px-4 py-2">Romania, Iceland, Finland</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2"><a href="https://billing.flokinet.is/" class="text-blue-500 hover:underline" target="_blank">View Page</a></td>
                </tr>
                <tr>
                    <td class="border px-4 py-2">Yourserver</td>
                    <td class="border px-4 py-2">Sweden, Latvia</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">No</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2"><a href="https://www.yourserver.se/" class="text-blue-500 hover:underline" target="_blank">View Page</a></td>
                </tr>
                <tr>
                    <td class="border px-4 py-2">PulseServers</td>
                    <td class="border px-4 py-2">Canada, United Kingdom</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2"><a href="https://pulseservers.com/" class="text-blue-500 hover:underline" target="_blank">View Page</a></td>
                </tr>
                <tr>
                    <td class="border px-4 py-2">LiteServer</td>
                    <td class="border px-4 py-2">Netherlands</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2"><a href="https://liteserver.nl/" class="text-blue-500 hover:underline" target="_blank">View Page</a></td>
                </tr>
                <tr>
                    <td class="border px-4 py-2">DigitalOcean</td>
                    <td class="border px-4 py-2">United States, Netherlands, Singapore, United Kingdom, Germany, Canada,
                        India</td>
                    <td class="border px-4 py-2">Yes</td>
                    <td class="border px-4 py-2">No</td>
                    <td class="border px-4 py-2">No</td>
                    <td class="border px-4 py-2"><a href="https://www.digitalocean.com/" class="text-blue-500 hover:underline" target="_blank">View Page</a></td>
                </tr>
            </tbody>
        </table>
        <p class="mt-4 text-gray-500 text-xs">
           We do not take any responsibility for the accuracy of the information provided here. Please check the hoster's
            terms of service before ordering a server.
        </p>
    </div>
</template>
