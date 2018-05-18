$(document).on('shiny:inputchanged', function(event) {
    if (event.name === 'comment_id') {
        $('#comment_content > div.active').toggleClass('active')
        $('#comment-' + event.value).toggleClass('active')
    }
});