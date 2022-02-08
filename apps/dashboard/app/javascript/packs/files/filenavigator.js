$(document).ready(function(){
    $("#btnFileNavigator").on("click", function(){
        var url = $("#relative_root_id").val();
        alert(url);
        window.open(url, "fileNavigator", "toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=800,height=600");
    });        
});
