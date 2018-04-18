/**
 * @author Thomas Wilkins
 * @date 4/11/2018
 * @description example template class
 */
@isTest
public class AccountTemplates {
	public class StandardAccountTemplate extends Template {
		protected override void init() {
			this.requiredFields = new Set<String> { 'Name' };
			this.defaultFields = new Map<String, Object> {
				'Name' => 'Test Account'
			};
		}
	}
	public class ErrorAccountTemplate extends Template {
		protected override void init() {
			this.requiredFields = new Set<String> { 'Name' };
			this.defaultFields = new Map<String, Object>();
		}
	}
}