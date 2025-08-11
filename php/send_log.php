<?php
	require_once('../class/common.php');
	require_once(SMARTY_DIR.'Smarty.class.php');
	$auth    = new Auth();
	$smarty  = new Smarty();
	$check   = new Check();
	$log_ana = new log_ana_class();

	# 認証
	$auth->action();
	# 機能認証
	$auth->approval(basename(__FILE__));
	
#print_r($_POST);

// Initialize array to store form data
$disp_arr = [];

// Initialize array to store error messages
$errors = [];

// Initialize array to store selected columns
$columns = [];

// Check if form was submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
  // Get form data
  $disp_arr = $_POST;

  // Check if columns were selected
  if (!empty($_POST['columns'])) {
      $columns = $_POST['columns'];
      foreach ($_POST['columns'] as $value) {
        $disp_arr["check"][$value] = "checked";
      }
  }
#print_r($disp_arr["check"]);
  
  // Validate required fields
  $required_fields = ['date_stamp', 'time_stamp_from', 'time_stamp_to', 'limit'];
  foreach ($required_fields as $field) {
    if (empty($disp_arr[$field])) {
      $errors[] = "The field {$field} is required.";
    }
    if ($field == "limit" and $disp_arr[$field] > 10000) {
      $errors[] = "Limitは10000以下にしてください";
    }
  }

  if (!empty($errors)) {
    // Assign errors to Smarty variable
    $smarty->assign('errors', $errors);
  } else {
    try {
      # log-dbの一覧作成
      $target_log_dbs = array();
      foreach ($log_dbs as $key => $value) {
      	$target_log_dbs[$value["host"]] = $value;
      }
      
      $results = array();
      foreach ($target_log_dbs as $key => $value) {
          // Connect to database
          $db = new PDO('mysql:host='.$value["host"].';dbname='.$value["name"].';charset=utf8mb4', $value["user"], $value["pass"]);

          // Initialize WHERE clause array
          $where = [];
          $params = [];

          // Build query with dynamic conditions
          $where[] = 's.date_stamp = :date_stamp';
          $params[':date_stamp'] = $disp_arr['date_stamp'];

          $where[] = 's.time_stamp >= :time_stamp_from';
          $params[':time_stamp_from'] = $disp_arr['time_stamp_from'];

          $where[] = 's.time_stamp <= :time_stamp_to';
          $params[':time_stamp_to'] = $disp_arr['time_stamp_to'].":59";

          if (!empty($disp_arr['userid'])) {
            $where[] = 's.userid = :userid';
            $params[':userid'] = $disp_arr['userid'];
          }

          if (!empty($disp_arr['status'])) {
            $status_arr = array();
            foreach ($disp_arr['status'] as $key => $value) {
              if ($value == 1) { $status_arr[] = "1"; $disp_arr["status_s1"] = "selected"; }
              if ($value == 2) { $status_arr[] = "0"; $disp_arr["status_s2"] = "selected"; }
              if ($value == 3) { $status_arr[] = "2"; $disp_arr["status_s3"] = "selected"; }
            }
            $where[] = sprintf("s.result IN (%s)",implode(",",$status_arr));
          }

          if (!empty($disp_arr['status_code'])) {
            $where[] = 's.status_code LIKE :status_code';
            $params[':status_code'] = '%' . $disp_arr['status_code'] . '%';
          }

          if (!empty($disp_arr['transaction_id'])) {
            $where[] = 's.transaction_id LIKE :transaction_id';
            $params[':transaction_id'] = '%' . $disp_arr['transaction_id'] . '%';
          }

          if (!empty($disp_arr['from_ip_address'])) {
            $where[] = 's.from_ip_address = :from_ip_address';
            $params[':from_ip_address'] = $disp_arr['from_ip_address'];
          }

          if (!empty($disp_arr['envelope_from_address'])) {
            $where[] = 's.envelope_from_address LIKE :envelope_from_address';
            $params[':envelope_from_address'] = '%' . $disp_arr['envelope_from_address'] . '%';
          }

          if (!empty($disp_arr['envelope_to_address'])) {
            $where[] = 's.envelope_to_address LIKE :envelope_to_address';
            $params[':envelope_to_address'] = '%' . $disp_arr['envelope_to_address'] . '%';
          }

          if (!empty($disp_arr['envelope_to_address_domain'])) {
            $where[] = 's.envelope_to_address_domain = :envelope_to_address_domain';
            $params[':envelope_to_address_domain'] = $disp_arr['envelope_to_address_domain'];
          }

          if (!empty($disp_arr['envelope_from_address_domain'])) {
            $where[] = 's.envelope_from_address_domain = :envelope_from_address_domain';
            $params[':envelope_from_address_domain'] = $disp_arr['envelope_from_address_domain'];
          }

          if (!empty($disp_arr['message'])) {
            $where[] = 's.message LIKE :message';
            $params[':message'] = '%' . $disp_arr['message'] . '%';
          }

          // Construct full SQL query
          $w_select = "";
          foreach ($_POST['columns'] as $key => $value) {
              if($value=="message_id") {
                  if($w_select) {
                      $w_select .= ",sac.message_id";
                  } else {
                      $w_select .= "sac.message_id";
                  }
              } elseif ($value=="processing_time") {
                  if($w_select) {
                      $w_select .= ",sac.processing_time";
                  } else {
                      $w_select .= "sac.processing_time";
                  }
              } else {
                  if($w_select) {
                      $w_select .= ",s.".$value;
                  } else {
                      $w_select .= "s.".$value;
                  }
              }
          }
          if (in_array('message_id', $_POST['columns']) or in_array('processing_time', $_POST['columns']) ) {
              $sql = "SELECT ". str_replace("s.status_code","substring(s.status_code,3,3) as status_code",$w_select)." FROM send_log s LEFT JOIN send_add_column sac ON s.id = sac.sid ";
          } else {
              $sql = "SELECT ". str_replace("s.status_code","substring(s.status_code,3,3) as status_code",$w_select)." FROM send_log s ";
          }
          if ($where) {
            $sql .= ' WHERE ' . implode(' AND ', $where);
          }
          $sql .= ' order by s.time_stamp,s.userid ';
          $sql .= ' LIMIT :limit';
          $params[':limit'] = (int)$disp_arr['limit'];
#echo $sql;
#print_r($params);
          // Prepare statement
#print_r($params);
#echo $sql;
          $stmt = $db->prepare($sql);

          // Bind parameters
          foreach ($params as $key => $value) {
              $stmt->bindValue($key, $value, is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR);
          }

          // Execute query
          $stmt->execute();
#      echo $stmt->debugDumpParams();
#      var_dump($stmt->fetchAll(PDO::FETCH_ASSOC));

          // Fetch results
          $tmp_results = $stmt->fetchAll(PDO::FETCH_ASSOC);
#print_r($tmp_results);
          $results = array_merge($results, $tmp_results);
#print_r($results);
#echo count($results);
      }

      // $resultsをtime_stampで昇順に並び替える
      usort($results, function($a, $b) {
          if ($a['time_stamp'] == $b['time_stamp']) {
              return 0;
          }
          return ($a['time_stamp'] < $b['time_stamp']) ? -1 : 1;
      });
#print_r($results);

      // 配列の要素数がlimitを超えている場合、最初のlimit数だけを保持
      if (count($results) > (int)$disp_arr['limit']) {
          $results = array_slice($results, 0, (int)$disp_arr['limit']);
      }
#print_r($results);


      // Assign results to Smarty variable
      $smarty->assign('results', $results);
      $disp_arr["record_count"] = count($results);
    } catch (PDOException $e) {
      // Handle error
      $errors[] = "Error: " . $e->getMessage();

      // Assign errors to Smarty variable
      $smarty->assign('errors', $errors);
    }
  }
}

# デフォルト表示
if(!$disp_arr["limit"]) { $disp_arr["limit"] = 10000; }
if(!isset($disp_arr["check"])) {
	$disp_arr["check"] = array(
							"date_stamp"=>"checked"
							,"time_stamp"=>"checked"
							,"userid"=>"checked"
							,"result"=>"checked"
							,"status_code"=>"checked"
							,"envelope_from_address"=>"checked"
							,"envelope_to_address"=>"checked"
							,"message"=>"checked"
							,"message_id"=>"checked"
							);
}
#echo $_SESSION["send_log"]["default"];
#print_r($results);

	# 画面表示
	$smarty->template_dir = SMARTY_TEMPLATE_DIR;
	$smarty->compile_dir  = SMARTY_COMPILE_DIR;
	$smarty->config_dir   = SMARTY_CONFIGS_DIR;
	$smarty->cache_dir    = SMARTY_CACHE_DIR;

// Assign form data to Smarty variable
$smarty->assign('title'   , "SEND LOG");
$smarty->assign('disp_arr', $disp_arr);
$smarty->assign('columns' , $columns);

// Display template
$smarty->display('send_log.tpl');
?>
