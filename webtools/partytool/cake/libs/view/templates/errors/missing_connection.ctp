<?php
/* SVN FILE: $Id: missing_connection.ctp,v 1.2 2007-11-19 08:49:55 rflint%ryanflint.com Exp $ */
/**
 *
 * PHP versions 4 and 5
 *
 * CakePHP(tm) :  Rapid Development Framework <http://www.cakephp.org/>
 * Copyright 2005-2007, Cake Software Foundation, Inc.
 *								1785 E. Sahara Avenue, Suite 490-204
 *								Las Vegas, Nevada 89104
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @filesource
 * @copyright		Copyright 2005-2007, Cake Software Foundation, Inc.
 * @link				http://www.cakefoundation.org/projects/info/cakephp CakePHP(tm) Project
 * @package			cake
 * @subpackage		cake.cake.libs.view.templates.errors
 * @since			CakePHP(tm) v 0.10.0.1076
 * @version			$Revision: 1.2 $
 * @modifiedby		$LastChangedBy: phpnut $
 * @lastmodified	$Date: 2007-11-19 08:49:55 $
 * @license			http://www.opensource.org/licenses/mit-license.php The MIT License
 */
?>
<h1><?php __('Requires a Database Connection'); ?></h1>
<?php echo sprintf(__('Confirm you have created the file : %s.', true), APP_DIR.DS."config".DS."database.php");?>
<p class="error"><?php echo sprintf(__('Missing Database Connection: %s requires a database connection', true), $model);?></p>
<p><span class="notice"><strong><?php __('Notice'); ?>: </strong>
<?php echo sprintf(__('If you want to customize this error message, create %s.', true), APP_DIR.DS."views".DS."errors".DS."missing_database.ctp");?></span></p>
<p><span class="notice"><strong><?php __('Fatal'); ?>: </strong>
<?php echo sprintf(__('Confirm you have created the file : %s.', true), APP_DIR.DS."config".DS."database.php");?></span></p>