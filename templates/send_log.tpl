<!DOCTYPE html>
<html lang="ja">
	<head>
		<meta charset="UTF-8">
		<title>{$title}</title>
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="robots" content="noindex,nofollow">
		<link rel="stylesheet" href="../css/bootstrap.min.css">
		<link rel="stylesheet" href="../css/custom.css">
		<script type="text/javascript" src="../js/jquery.js"></script>
		<script type="text/javascript" src="../js/bootstrap.bundle.js"></script>
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
		<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
		<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ja.js"></script>
		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery.tablesorter/2.31.0/js/jquery.tablesorter.min.js"></script>
		<script>
			$(function() {
				$("#header").load("header.php");
			});
			$(document).ready(function() {
				$('#user_table').tablesorter();
			});
		</script>
		<style>
			.table td, .table th {
			border: 1px solid #dee2e6;
		}
</style>
	</head>
  
<body>
    <div class="custom-container-90">
			<div id="header"></div>
 		
 		<div class="container mt-3"></div>
        <p>◆Send Log◆</p>
        <form action="send_log.php" method="post">
            <div class="form-group form-inline">
                <label for="date_stamp">Date（必須）: 　</label>
                <input type="text" class="form-control" id="date_stamp" name="date_stamp" value="{$disp_arr.date_stamp}" required>
            </div>
            <div class="form-group form-inline">
                <label for="time_stamp">Time（必須）:　</label>
                <input type="time" class="form-control" id="time_stamp_from" name="time_stamp_from" value="{$disp_arr.time_stamp_from}" required>
                　～　
                <input type="time" class="form-control" id="time_stamp_to" name="time_stamp_to" value="{$disp_arr.time_stamp_to}" required>
            </div>
            <div class="form-group form-inline">
                <label for="userid">User ID:　</label>
                <input type="text" class="form-control" id="userid" name="userid" value="{$disp_arr.userid}">
            </div>
            <div class="form-group">
                <label for="result">Status:</label>
                <select class="form-control" id="status" name="status[]" multiple>
                    <option value="1" {$disp_arr.status_s1}>正常(1)</option>
                    <option value="2" {$disp_arr.status_s2}>エラー(0)</option>
                    <option value="3" {$disp_arr.status_s3}>リトライ(2)</option>
                </select>
            </div>
            <div class="form-group form-inline">
                <label for="envelope_to_address">Envelope To Address:　</label>
                <input type="text" class="form-control" id="envelope_to_address" name="envelope_to_address" value="{$disp_arr.envelope_to_address}">
                　
                <label for="envelope_to_address_domain">Envelope To Address Domain:　</label>
                <input type="text" class="form-control" id="envelope_to_address_domain" name="envelope_to_address_domain" value="{$disp_arr.envelope_to_address_domain}">
            </div>
            <div class="form-group form-inline">
                <label for="envelope_from_address">Envelope From Address:　</label>
                <input type="text" class="form-control" id="envelope_from_address" name="envelope_from_address" value="{$disp_arr.envelope_from_address}">
                　
                <label for="envelope_from_address_domain">Envelope From Address Domain:　</label>
                <input type="text" class="form-control" id="envelope_from_address_domain" name="envelope_from_address_domain" value="{$disp_arr.envelope_from_address_domain}">
            </div>
            <div class="form-group form-inline">
                <label for="from_ip_address">From IP Address:　</label>
                <input type="text" class="form-control" id="from_ip_address" name="from_ip_address" value="{$disp_arr.from_ip_address}">
                　
                <label for="status_code">Status Code:　</label>
                <input type="text" class="form-control" id="status_code" name="status_code" value="{$disp_arr.status_code}">
                　
                <label for="transaction_id">Transaction ID:　</label>
                <input type="text" class="form-control" id="transaction_id" name="transaction_id" value="{$disp_arr.transaction_id}">
            </div>
            <div class="form-group">
                <label for="message">Message:</label>
                <input type="text" class="form-control" id="message" name="message" value="{$disp_arr.message}">
            </div>
            <div class="form-group form-inline">
                <label for="limit">Limit（必須）（10000まで）:　</label>
                <input type="number" class="form-control" id="limit" name="limit" value="{$disp_arr.limit}" required>
            </div>
            <div class="form-group">
                <label for="Columns">Select Table Columns:　</label><br />
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_date" name="columns[]" value="date_stamp" {$disp_arr.check.date_stamp}>
                    <label class="form-check-label" for="column_date">Date</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_time" name="columns[]" value="time_stamp" {$disp_arr.check.time_stamp}>
                    <label class="form-check-label" for="column_time">Time</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_userid" name="columns[]" value="userid" {$disp_arr.check.userid}>
                    <label class="form-check-label" for="column_userid">UserID</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_result" name="columns[]" value="result" {$disp_arr.check.result}>
                    <label class="form-check-label" for="column_userid">Result</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_status_code" name="columns[]" value="status_code" {$disp_arr.check.status_code}>
                    <label class="form-check-label" for="column_status_code">Status Code</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_transaction_id" name="columns[]" value="transaction_id" {$disp_arr.check.transaction_id}>
                    <label class="form-check-label" for="column_transaction_id">Transaction ID</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="columnfrom_ip_address" name="columns[]" value="from_ip_address" {$disp_arr.check.from_ip_address}>
                    <label class="form-check-label" for="column_from_ip_address">From IP Address</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_envelope_from_address" name="columns[]" value="envelope_from_address" {$disp_arr.check.envelope_from_address}>
                    <label class="form-check-label" for="column_envelope_from_address">Envelope From Address</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_envelope_to_address" name="columns[]" value="envelope_to_address" {$disp_arr.check.envelope_to_address}>
                    <label class="form-check-label" for="column_envelope_to_address">Envelope To Address</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_to_ip_address_port" name="columns[]" value="to_ip_address_port" {$disp_arr.check.to_ip_address_port}>
                    <label class="form-check-label" for="column_to_ip_address_port">To IP Address Port</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_source_ip_address_port" name="columns[]" value="source_ip_address_port" {$disp_arr.check.source_ip_address_port}>
                    <label class="form-check-label" for="column_source_ip_address_port">Source IP Address Port</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_envelope_to_address_domain" name="columns[]" value="envelope_to_address_domain" {$disp_arr.check.envelope_to_address_domain}>
                    <label class="form-check-label" for="column_envelope_to_address_domain">Envelope To Address Domain</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_envelope_from_address_domain" name="columns[]" value="envelope_from_address_domain" {$disp_arr.check.envelope_from_address_domain}>
                    <label class="form-check-label" for="column_envelope_from_address_domain">Envelope From Address Domain</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_message" name="columns[]" value="message" {$disp_arr.check.message}>
                    <label class="form-check-label" for="column_message">Message</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_message_id" name="columns[]" value="message_id" {$disp_arr.check.message_id}>
                    <label class="form-check-label" for="column_message_id">Message-ID</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" id="column_processing_time" name="columns[]" value="processing_time" {$disp_arr.check.processing_time}>
                    <label class="form-check-label" for="column_processing_time">Processing Time</label>
                </div>
                <!-- Repeat above div for each column in the table, change id, name and label text -->
            </div>
            <button type="submit" class="btn btn-primary">Submit</button>
        </form>

        {if $errors}
        <div class="container mt-3"></div>
        <div class="alert alert-danger">
            <ul>
            {foreach from=$errors item=error}
                <li>{$error}</li>
            {/foreach}
            </ul>
        </div>
        {/if}

        {if $results}
        <div class="container mt-3"></div>
        	<p>表示件数： {$disp_arr.record_count|number_format} 件   ※件数がlimitと同じ時は表示されてないレコードがあります</p>
            <div class="results">
                <table class="table" id="user_table">
                    <thead>
                        <tr>
                            {foreach from=$columns item=column}
                              {if $column == 'date_stamp'}<th>Date</th>{/if}
                              {if $column == 'time_stamp'}<th>Time</th>{/if}
                              {if $column == 'userid'}<th>UserID</th>{/if}
                              {if $column == 'result'}<th>Result</th>{/if}
                              {if $column == 'status_code'}<th>Status Code</th>{/if}
                              {if $column == 'transaction_id'}<th>Transaction ID</th>{/if}
                              {if $column == 'from_ip_address'}<th>From IP Address</th>{/if}
                              {if $column == 'envelope_from_address'}<th>Envelope From Address</th>{/if}
                              {if $column == 'envelope_to_address'}<th>Envelope To Address</th>{/if}
                              {if $column == 'to_ip_address_port'}<th>To IP Address Port</th>{/if}
                              {if $column == 'source_ip_address_port'}<th>Source IP Address Port</th>{/if}
                              {if $column == 'envelope_to_address_domain'}<th>Envelope To Address Domain</th>{/if}
                              {if $column == 'envelope_from_address_domain'}<th>nvelope From Address Domain</th>{/if}
                              {if $column == 'message'}<th>Message</th>{/if}
                              {if $column == 'message_id'}<th>Message-ID</th>{/if}
                              {if $column == 'processing_time'}<th>Processing Time</th>{/if}
                            {/foreach}
                        </tr>
                    </thead>
                    <tbody>
                    {foreach from=$results item=result}
                        <tr>
                            {foreach from=$columns item=column}
                              {if $column == 'date_stamp'}<td>{$result.date_stamp}</td>{/if}
                              {if $column == 'time_stamp'}<td>{$result.time_stamp}</td>{/if}
                              {if $column == 'userid'}<td>{$result.userid}</td>{/if}
                              {if $column == 'result'}<td>{$result.result}</td>{/if}
                              {if $column == 'status_code'}<td>{$result.status_code}</td>{/if}
                              {if $column == 'transaction_id'}<td>{$result.transaction_id}</td>{/if}
                              {if $column == 'from_ip_address'}<td>{$result.from_ip_address}</td>{/if}
                              {if $column == 'envelope_from_address'}<td>{$result.envelope_from_address}</td>{/if}
                              {if $column == 'envelope_to_address'}<td>{$result.envelope_to_address}</td>{/if}
                              {if $column == 'to_ip_address_port'}<td>{$result.to_ip_address_port}</td>{/if}
                              {if $column == 'source_ip_address_port'}<td>{$result.source_ip_address_port}</td>{/if}
                              {if $column == 'envelope_to_address_domain'}<td>{$result.envelope_to_address_domain}</td>{/if}
                              {if $column == 'envelope_from_address_domain'}<td>{$result.envelope_from_address_domain}</td>{/if}
                              {if $column == 'message'}<td>{$result.message}</td>{/if}
                              {if $column == 'message_id'}<td>{$result.message_id|escape:'html'}</td>{/if}
                              {if $column == 'processing_time'}<td>{$result.processing_time}</td>{/if}
                            {/foreach}
                        </tr>
                    {/foreach}
                    </tbody>
                </table>
            </div>
        {/if}
    </div>
		<script>
			flatpickr("#date_stamp", {
				dateFormat: "Y/m/d",
			});
		</script>
</body>
</html>
