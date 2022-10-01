(async () => {
    const response = await fetch('https://api.github.com/repos/mineiwik/LD51/contents/?ref=github-pages');
    const data = await response.json();

    let htmlString = '';
    let paths = [];

    data.sort((a, b) => b.name.localeCompare(a.name))

    for (let file of data) {
        if (file.type === "dir" && /^\d/.test(file.name)) {
            paths.push(file.path)
            htmlString += `<span><a href="${file.path}">${file.name}</a></span><br/>`;
        }
    }

    if (paths.length > 0) {
        htmlString = `<span><a href="${paths.sort().reverse()[0]}">Latest</a></span><br/>` + htmlString;
    }


    document.getElementsByClassName('dsg-links')[0].innerHTML = htmlString;
})()