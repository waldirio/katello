/**
 Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

(function(){
	KT.panel.registerPage('users');
})();

$(document).ready(function() {
   
    KT.user_page.registerEdits();

    KT.panel.set_expand_cb(function() {
        //taken out of user_edit, so it can be resused on accounts
        $(".multiselect").multiselect({"dividerLocation":0.5, "sortable":false});
    })

});

