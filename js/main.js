$(function(){

    /* --- Event handlers --- */

    $("#add_another_author").click(function() {

        /* Declare local variables */

        var iAdditionalAuthorCount;
        var oAdditionalAuthors;
        var oAuthorTypeFieldClone;
        var sFirstId;
        var sNewId;

        /* Initialize local variables */

        // (DOM) Get divs by id
        oAdditionalAuthors = $("#additional_authors");
        oAuthorTypeFieldClone = $("#author_0_type").clone();

        /* Execute */

        // Get the ID of the first author
        sFirstId = oAuthorTypeFieldClone[0].id;

        // Get count of additional authors already added
        iAdditionalAuthorCount = oAdditionalAuthors.children().length;

        // Create new ID based on how many additional authors already exist
        sNewId = IncrementId(sFirstId, 1, iAdditionalAuthorCount);

        // Assign new ID to the clone
        oAuthorTypeFieldClone[0].id = sNewId;

        // Insert clone into group of additional authors
        oAdditionalAuthors.append(oAuthorTypeFieldClone[0]);

        /* Final */

        // Return nothing
        return;

        /* --- Local Functions --- */

        function IncrementId(sId, iElementIndex, iCount) {
            
            /* Declare local variables */
            
            var aIdParts;
            var sNewId;

            /* Execute */

            // Split ID string up into an array, for easier manipulation
            aIdParts = sId.split("_");

            // Do some arithmetic, and replace the specified element in the array
            aIdParts[iElementIndex] = iCount + 1;

            // Reconstruct string with new ID
            sNewId = aIdParts.join("_");

            /* Final */

            // Return the new ID
            return sNewId;
        }
    });
});