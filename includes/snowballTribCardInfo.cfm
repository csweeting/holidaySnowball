<cfoutput>
<!-- Acknowledgement card form -->
        <section class="js_bcchf_ack_card_container">
            <form class="bcchf_step js_bcchf_ack_card" name="js_bcchf_ack_card" id="js_bcchf_ack_card" action="" method="post">
            	<input type="hidden" name="tUUID" id="tUUID" value="#sup_pge_UUID#" />
                <input type="hidden" name="hiddenTributeType" id="hiddenTributeType" value="#AWKcardMSG#" />
                <h2>Please fill out the information below to send your acknowledgement message.</h2>
                <p class="bcchf_message"><em>Fields with and * are required</em></p>

                <div class="bcchf_input_container">
                    <label for="bcchf_in_memory">In #AWKcardMSG# of:</label>
                    <input type="text" id="bcchf_in_memory" name="bcchf_in_memory" value="#selectTransaction.trb_lname#"/>
                    <span class="bcchf_valid_checkmark"></span>
                    <p class="bcchf_message error hide"><em></em></p>
                </div>

                <!-- Send card by -->
                <section>
                    <label class="bcchf_stack_label">Send my card by: </label>
                    <input type="radio" id="bcchf_send_by_email" name="bcchf_send_card" value="email" checked required/>
                    <label class="bcchf_btn" for="bcchf_send_by_email">Email</label>
                    <input type="radio" id="bcchf_send_by_post" name="bcchf_send_card" value="mail" required/>
                    <label class="bcchf_btn" for="bcchf_send_by_post">Post Mail</label>
                    <p class="bcchf_message error hide"><em></em></p>
                </section>

                <!-- Receipient name -->
                <p class="bcchf_titles">Who is this card for:</p>
                <div class="bcchf_input_container js_bcchf_input_container">
                    <label for="bcchf_first_name">Recipient first name*:</label>
                    <input type="text" id="bcchf_first_name" name="bcchf_first_name" required/>
                    <span class="bcchf_valid_checkmark"></span>
                    <p class="bcchf_message error hide"><em></em></p>
                </div>
                <div class="bcchf_input_container js_bcchf_input_container">
                    <label for="bcchf_last_name">Recipient last name*:</label>
                    <input type="text" id="bcchf_last_name" name="bcchf_last_name" required/>
                    <span class="bcchf_valid_checkmark"></span>
                    <p class="bcchf_message error hide"><em></em></p>
                </div>

                <!-- Receipient information if sending by Email -->
                <section class="js_bcchf_send_card" id="js_bcchf_send_by_email">
                    <!-- <div class="bcchf_input_container">
                        <label for="bcchf_acknowledgement_of">In acknowledgement of:</label>
                        <input type="text" id="bcchf_acknowledgement_of" name="bcchf_acknowledgement_of"/>
                    </div> -->
                    <div class="bcchf_input_container js_bcchf_input_container">
                        <label for="bcchf_email" >Recipient email*:</label>
                        <input type="email" id="bcchf_email" name="bcchf_email" required/>
                        <span class="bcchf_valid_checkmark"></span>
                        <p class="bcchf_message error hide"><em></em></p>
                    </div>
                </section>

                <!-- Receipient information if sending by Post -->
                <section class="js_bcchf_send_card hide" id="js_bcchf_send_by_post">
                    <!-- Address -->
                    <div class="bcchf_input_container js_bcchf_input_container">
                        <label for="bcchf_address">Address 1*:</label>
                        <input type="text" id="bcchf_address" name="bcchf_address" required/>
                        <span class="bcchf_valid_checkmark"></span>
                        <p class="bcchf_message error hide"><em></em></p>
                    </div>

                    <!-- Address 2 -->
                    <div class="bcchf_input_container">
                        <label for="bcchf_address2">Address 2:</label>
                        <input type="text" id="bcchf_address2" name="bcchf_address2"/>
                        <span class="bcchf_valid_checkmark"></span>
                        <p class="bcchf_message error hide"><em></em></p>
                    </div>

                    <!-- City -->
                    <div class="bcchf_input_container js_bcchf_input_container">
                        <label for="bcchf_city">City*:</label>
                        <input type="text" id="bcchf_city" name="bcchf_city" required/>
                        <span class="bcchf_valid_checkmark"></span>
                        <p class="bcchf_message error hide"><em></em></p>
                    </div>

                    <!-- Province -->
                    <div class="bcchf_input_container js_bcchf_input_container">
                        <label for="bcchf_province">Province*:</label>
                        <input type="text" id="bcchf_province" name="bcchf_province" value="BC" required/>
                        <span class="bcchf_valid_checkmark"></span>
                        <p class="bcchf_message error hide"><em></em></p>
                    </div>
                    
                    

                    <!-- Postal Code -->
                    <!-- <div class="bcchf_input_container js_bcchf_input_container">
                    <label for="bcchf_postal_code">Postal Code*:</label>
                    <input type="text" id="bcchf_postal_code" name="bcchf_postal_code" required/>
                    <span class="bcchf_valid_checkmark"></span>
                    <p class="bcchf_message error hide"><em>Please enter your postal code.</em></p>
                </div> -->
                <div class="bcchf_input_container js_bcchf_input_container">
                    <label for="bcchf_postal_code">Postal Code*:</label>
                    <input type="text" id="bcchf_postal_code" name="bcchf_postal_code" required/>
                    <span class="bcchf_valid_checkmark"></span>
                    <p class="bcchf_message error hide"><em>Please enter your postal code.</em></p>
                </div>

                <!-- Country -->
                <div class="bcchf_input_container js_bcchf_input_container">
                        <label for="bcchf_country">Country*:</label>
                        <input type="text" id="bcchf_country" name="bcchf_country" value="Canada" required/>
                        <span class="bcchf_valid_checkmark"></span>
                        <p class="bcchf_message error hide"><em></em></p>
                    </div>
                    
                    
                
            </section>

            <!-- Personalized Message -->
            <section>
                <div class="bcchf_text_container js_bcchf_text_container">
                    <label class="bcchf_stack_label">Your personalized message:*:</label>
                    <textarea name="bcchf_acknowledgement_msg" required></textarea>
                    <span class="bcchf_valid_checkmark"></span>
                    <p class="bcchf_message error hide"><em></em></p>
                </div>
                <div class="bcchf_input_container js_bcchf_input_container">
                    <label for="bcchf_sign">Sign your letter*:</label>
                    <input type="text" id="bcchf_sign" name="bcchf_sign" required/>
                    <span class="bcchf_valid_checkmark"></span>
                    <p class="bcchf_message error hide"><em></em></p>
                </div>
            </section>
            <button class="bcchf_next js_bcchf_next" type="submit">Send Card</button>
        </form>
        <div class="hide" id="tribCardThankYouEmail">
        <h2>Thank You</h2>
        <h1>Your message is being prepared.</h1>
        </div>
        <div class="hide" id="tribCardThankYouPost">
        <h2>Thank You</h2>
        <h1>Your message will be sent</h1>
        </div>
    </section>
</cfoutput>