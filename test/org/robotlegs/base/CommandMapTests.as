/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.flexunit.Assert;
	import org.robotlegs.adapters.SwiftSuspendersInjector;
	import org.robotlegs.base.CommandMap;
	import org.robotlegs.core.ICommandMap;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.mvcs.support.ICommandTest;
	import org.robotlegs.mvcs.support.EventCommand;
	import org.robotlegs.mvcs.support.CustomEvent;
	
	public class CommandMapTests implements ICommandTest
	{
		protected var eventDispatcher:IEventDispatcher;
		protected var commandExecuted:Boolean;
		protected var commandMap:ICommandMap;
		protected var injector:IInjector;
		
		[BeforeClass]
		public static function runBeforeEntireSuite():void
		{
		}
		
		[AfterClass]
		public static function runAfterEntireSuite():void
		{
		}
		
		[Before]
		public function runBeforeEachTest():void
		{
			eventDispatcher = new EventDispatcher();
			injector = new SwiftSuspendersInjector();
			commandMap = new CommandMap(eventDispatcher, injector);
			injector.mapValue(ICommandTest, this);
		}
		
		[After]
		public function runAfterEachTest():void
		{
			injector.unmap(ICommandTest);
			resetCommandExecuted();
		}
		
		[Test]
		public function noCommand():void
		{
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertFalse('Command should not have reponded to event', commandExecuted);
		}
		
		[Test]
		public function hasCommand():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, EventCommand);
			var hasCommand:Boolean = commandMap.hasEventCommand(CustomEvent.STARTED, EventCommand);
			Assert.assertTrue('Command Map should have Command', hasCommand);
		}
		
		[Test]
		public function normalCommand():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, EventCommand);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
		}
		
		[Test]
		public function normalCommandRepeated():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, EventCommand);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
			resetCommandExecuted();
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event again', commandExecuted);
		}
		
		[Test]
		public function oneshotCommand():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, EventCommand, null, true);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
			resetCommandExecuted();
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertFalse('Command should NOT have reponded to event', commandExecuted);
		}
		
		[Test]
		public function normalCommandRemoved():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, EventCommand);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertTrue('Command should have reponded to event', commandExecuted);
			resetCommandExecuted();
			commandMap.unmapEvent(CustomEvent.STARTED, EventCommand);
			eventDispatcher.dispatchEvent(new CustomEvent(CustomEvent.STARTED));
			Assert.assertFalse('Command should NOT have reponded to event', commandExecuted);
		}
		
		[Test(expects="org.robotlegs.base.ContextError")]
		public function mappingNonCommandClassShouldFail():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, Object);
		}
		
		[Test(expects="org.robotlegs.base.ContextError")]
		public function mappingSameThingTwiceShouldFail():void
		{
			commandMap.mapEvent(CustomEvent.STARTED, EventCommand);
			commandMap.mapEvent(CustomEvent.STARTED, EventCommand);
		}
		
		public function markCommandExecuted():void
		{
			commandExecuted = true;
		}
		
		public function resetCommandExecuted():void
		{
			commandExecuted = false;
		}
	}
}