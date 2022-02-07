$(document).ready(function(){
    $("#btnFileNavigator").on("click", function(){
        var url = '/pun/dev/dashboard/files/fs/home/gbyrket';
        window.open(url, "fileNavigator", "toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=800,height=600");
    });        
});
