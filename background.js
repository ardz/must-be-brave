fetch(browser.runtime.getURL("config.json"))
    .then(response => response.json())
    .then(config => {
        const customHandlerName = config.customHandlerName;

        browser.browserAction.onClicked.addListener((tab) => {
            const url = encodeURIComponent(tab.url);
            const braveUrl = `${customHandlerName}:${url}`;
            browser.tabs.create({ url: braveUrl });
        });
    });
