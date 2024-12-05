'use strict';

jQuery(function (){
    let attachmentIdCounter = 0;

    function createId() {
        return `attachment_id_${++attachmentIdCounter}`;
    }

    function fileSizeToString(number) {
        if(number < 1024) {
            return number + "bytes";
        } else if(number >= 1024 && number < 1048576) {
            return (number/1024).toFixed(1) + "KB";
        } else if(number >= 1048576) {
            return (number/1048576).toFixed(1) + "MB";
        }
    }

    function validateForm(event) {
        const validForm = $("#new_support_ticket")[0].reportValidity();
        if(!validForm) {
            event.preventDefault();
            return;
        }

        //SHOW FULL PAGE SPINNER
        $("body").addClass("modal-open");
        $("#full-page-spinner").removeClass('d-none');
    }

    function clearAttachmentsError() {
        const $errorElement = $("#attachments_error");
        $errorElement.parent().removeClass("has-error");
        $errorElement.remove();
    }

    function showAttachmentsError(message) {
        const $attachmentsElement = $("[data-bs-toggle='attachments-error']");
        $attachmentsElement.parent().addClass("has-error");
        $attachmentsElement.after(`<div class="help-block" id="attachments_error">${message}</div>`);
    }

    function deleteAttachment(event) {
        clearAttachmentsError();
        const attachmentContainerId = event.currentTarget.getAttribute("data-attachment-container");
        $(`#${attachmentContainerId}`).remove();
    }

    function updateAttachmentContent(event) {
        clearAttachmentsError();
        const $fileElement = $(event.currentTarget);
        const files = $fileElement.prop('files');
        if (!files || files.length === 0) {
            return;
        }

        const fileInfo = files[0];
        if(fileInfo.size > SUPPORT_TICKET_RESTRICTIONS.max_size) {
            createAttachmentElement((newAttachment) => {
                $fileElement.parent().replaceWith(newAttachment);
            });
            const message = SUPPORT_TICKET_MESSAGES["size.attachments"].replace("%{max}", fileSizeToString(SUPPORT_TICKET_RESTRICTIONS.max_size)).replace("%{size}", fileSizeToString(fileInfo.size));
            showAttachmentsError(message);
            return;
        }

        const fileInputId = event.currentTarget.id;
        $(`label[for='${fileInputId}']`).text(`Selected file: ${fileInfo.name} (${fileSizeToString(fileInfo.size)}).`);
    }

    function createAttachmentElement(attachmentPlacementCallback) {
        const newAttachmentContainerId = createId();
        const newFileInputId = createId();
        const newAttachment =
        `<div class="attachment-input" id="${newAttachmentContainerId}">
           <div class="form-control attachment-input-content">
              <label class="attachment-file-label" for="${newFileInputId}">No file selected</label>
              <span class="attachment-delete" data-bs-toggle="attachment-delete" data-attachment-container="${newAttachmentContainerId}" title="Delete attachment"><i class="fas fa-trash-alt"></i></span>
           </div>
           <input class="form-control"  type="file" name="support_ticket[attachments][]" id="${newFileInputId}">
        </div>`;

        attachmentPlacementCallback(newAttachment);
        $("input[type='file']").on("change", updateAttachmentContent);
        $("[data-bs-toggle='attachment-delete']").on("click", deleteAttachment);
        return newAttachment;
    }

    function addAttachment() {
        clearAttachmentsError();
        if($("input[type='file']").length >= SUPPORT_TICKET_RESTRICTIONS.max_items ) {
            showAttachmentsError(SUPPORT_TICKET_MESSAGES["items.attachments"]);
            return;
        }

        createAttachmentElement((newAttachment) => {
            $("#attachments-container").append(newAttachment);
        });
    }

    $(function() {
        $("[data-bs-toggle='attachments-add']").on("click", addAttachment);
        $("#new_support_ticket").submit(validateForm);
    });

});