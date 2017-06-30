<?php
function execute_command( $cmd ) {
	while ( @ ob_end_flush() ); // end all output buffers if any

	$process = popen( "$cmd 2>&1 ; echo Exit status : $?", 'r' );

	$complete_output = "";

	while ( ! feof( $process ) ) {
		$live_output     = fread( $process, 4096 );
		$complete_output = $complete_output . $live_output;
		@ flush();
	}

	pclose( $process );

	// get exit status
	preg_match( '/[0-9]+$/', $complete_output, $matches );

	// return exit status and intended output
	return array (
		'exit_status' => intval( $matches[0] ),
		'output'      => str_replace( 'Exit status : ' . $matches[0], '', $complete_output ),
	);
}
?>
<html>
	<head>
		<title>Overscores</title>
	</head>
	<body>
		<?php
		if ( isset( $_POST['name'] ) ) {
			$name = filter_var( $_POST['name'], FILTER_SANITIZE_STRING );
			$cmd  = './init-plugin.sh "' . $name . '"';

			$result = execute_command( $cmd );

			if( $result['exit_status'] === 0 ) {
				$file = strtolower( str_replace( ' ', '-', $name ) ) . '.tar.gz';
				?>
				<script language="javascript">
					window.addEventListener( 'DOMContentLoaded', function() {
						window.location = window.location.href + '<?php echo $file; ?>';
					}, false );
				</script>
				<?php
			} else {
				echo '<pre>' . $result['output'] . '</pre>';
			}
		}
		?>
		<form method="post">
			<p>
				<label for="name">Name</label>
				<input type="text" name="name" id="name" />
			</p>
			<p>
				<input type="submit" value="Generate Overscores Plugin" />
			</p>
		</form>
	</body>
</html>
